import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson(req);
  const url = String(body.url ?? "").trim();

  if (!url.startsWith("http")) {
    return jsonResponse({ error: "valid url is required" }, 400);
  }

  // Replace with metadata scraping, OpenGraph parsing, and merchant normalization.
  return jsonResponse({
    item: {
      title: new URL(url).hostname.replace(/^www\./, ""),
      brand: "Linked Product",
      price: null,
      currencyCode: "USD",
      sourceURL: url,
      buyURL: url,
      imageURL: null,
    },
  });
});

