import { NextResponse, type NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: NextRequest) {
  const { searchParams, origin } = request.nextUrl;
  const code = searchParams.get("code");
  const next = searchParams.get("next") || "/onboarding";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      const destination = new URL(next, origin);
      if (destination.origin !== origin) destination.pathname = "/onboarding";
      return NextResponse.redirect(destination);
    }
  }

  return NextResponse.redirect(new URL("/login?error=confirmation", origin));
}
