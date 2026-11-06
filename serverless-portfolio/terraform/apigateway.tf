# ------------------------------------------------------------
# API Gateway : HTTP API (v2)。REST API より大幅に安く、レイテンシも低い。
# CloudFront 経由でのみ叩かせるため CORS 設定は不要 (同一オリジンになる)。
# ------------------------------------------------------------
resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

# CloudFront のビヘイビア /api/* をそのまま転送するので、ルートも /api を含める
resource "aws_apigatewayv2_route" "get_visits" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /api/visits"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "post_visits" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /api/visits"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 20 # 踏み台にされて課金が跳ねるのを防ぐ
    throttling_rate_limit  = 10
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
