import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson(req);
  const query = String(body.query ?? "").trim();

  if (!query) {
    return jsonResponse({ error: "query is required" }, 400);
  }

  // Replace with SerpAPI or another product search provider.
  return jsonResponse({
    results: [
      {
        title: `${query} Studio Edition`,
        brand: "Stacks Market",
        price: 64,
        currencyCode: "USD",
        sourceURL: `https://example.com/products/${encodeURIComponent(query)}`,
        imageURL: null,
        shortDescription: `A clean, collectible take on ${query}.`,
      },
    ],
  });
});

