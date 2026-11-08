import { Controller, Get } from "@nestjs/common";

@Controller("health")
export class HealthController {
  @Get()
  check() {
    return {
      status: "ok",
      service: "lien-hoa-accounting-ai-api",
      version: "0.1.0"
    };
  }
}
