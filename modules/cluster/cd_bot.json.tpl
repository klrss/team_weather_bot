[
  {
    "name": "${app_name}-${env}-bot",
    "image": "${app_image}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": "${app_port}",
        "hostPort": "${app_port}"
      }
    ],
    "environment": [
      {
        "name": "VERSION",
        "value": "${image_tag}"
      }
    ]
  }
]