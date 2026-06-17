import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson(req);
  const imageURL = String(body.imageURL ?? "").trim();

  if (!imageURL.startsWith("http")) {
    return jsonResponse({ error: "imageURL is required" }, 400);
  }

  // Replace with Replicate rembg. Store the output in Supabase Storage and return that URL.
  return jsonResponse({
    status: "complete",
    removedBackgroundImageURL: imageURL,
  });
});

