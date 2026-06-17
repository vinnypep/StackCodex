import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);
  const stackID = url.searchParams.get("stackID");

  if (!stackID) {
    return jsonResponse({ error: "stackID is required" }, 400);
  }

  // Replace with a read-only Supabase query used by the public web preview.
  return jsonResponse({
    stack: {
      id: stackID,
      title: "Hello",
      author: "Isabella Martinez",
      items: [],
    },
  });
});

