// ------------------------------------------------------------
// アクセスカウンター API
//   GET  /api/visits  → 現在値を返す
//   POST /api/visits  → +1 して返す
// SDK v3 は Lambda ランタイムに同梱されているため node_modules 不要 = zip が軽い
// ------------------------------------------------------------
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.TABLE_NAME;
const KEY = { pk: "visits#total" };

const json = (statusCode, body) => ({
  statusCode,
  headers: { "content-type": "application/json" },
  body: JSON.stringify(body),
});

export const handler = async (event) => {
  const method = event.requestContext?.http?.method ?? "GET";

  // 構造化ログ。CloudWatch Logs Insights でクエリしやすくする
  console.log(JSON.stringify({ level: "info", method, requestId: event.requestContext?.requestId }));

  try {
    if (method === "POST") {
      const res = await ddb.send(
        new UpdateCommand({
          TableName: TABLE,
          Key: KEY,
          UpdateExpression: "ADD #c :one",
          ExpressionAttributeNames: { "#c": "count" },
          ExpressionAttributeValues: { ":one": 1 },
          ReturnValues: "UPDATED_NEW",
        })
      );
      return json(200, { count: res.Attributes?.count ?? 0 });
    }

    const res = await ddb.send(new GetCommand({ TableName: TABLE, Key: KEY }));
    return json(200, { count: res.Item?.count ?? 0 });
  } catch (err) {
    console.error(JSON.stringify({ level: "error", message: err.message }));
    return json(500, { message: "internal server error" });
  }
};
