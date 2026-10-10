import { serve } from "bun";
import { readFileSync, writeFileSync, existsSync } from "fs";

const RATE_LIMIT_WINDOW_MS = 60000;
const MAX_REQUESTS_PER_WINDOW = 5;
const ipRequests = new Map<string, number[]>();

const DATA_DIR = process.env.DATA_DIR || "/data";
const CONFIG_FILE = `${DATA_DIR}/config.json`;
const RESERVATIONS_FILE = `${DATA_DIR}/reservations.json`;

if (!existsSync(RESERVATIONS_FILE)) {
  writeFileSync(RESERVATIONS_FILE, "[]", "utf-8");
}

function isRateLimited(ip: string): boolean {
  const now = Date.now();
  const requests = ipRequests.get(ip) || [];
  const recentRequests = requests.filter(
    (timestamp) => now - timestamp < RATE_LIMIT_WINDOW_MS,
  );

  if (recentRequests.length >= MAX_REQUESTS_PER_WINDOW) {
    return true;
  }

  recentRequests.push(now);
  ipRequests.set(ip, recentRequests);
  return false;
}

serve({
  port: 8086,
  async fetch(req) {
    const url = new URL(req.url);
    const clientIp = req.headers.get("x-forwarded-for") || "unknown";

    if (req.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "https://tristangrlt.github.io",
          "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type",
        },
      });
    }

    const headers = {
      "Access-Control-Allow-Origin": "https://tristangrlt.github.io",
      "Content-Type": "application/json",
    };

    if (isRateLimited(clientIp)) {
      return new Response(
        JSON.stringify({ error: "Trop de requêtes, veuillez patienter." }),
        { status: 429, headers },
      );
    }

    if (req.method === "GET" && url.pathname === "/api/slots") {
      const config = JSON.parse(readFileSync(CONFIG_FILE, "utf-8"));
      const reservations = JSON.parse(readFileSync(RESERVATIONS_FILE, "utf-8"));

      const slotsWithAvailability = config.slots.map((slot: any) => {
        const booked = reservations.filter(
          (r: any) => r.slot_id === slot.id,
        ).length;
        return { ...slot, remaining: Math.max(0, slot.capacity - booked) };
      });

      return new Response(JSON.stringify(slotsWithAvailability), { headers });
    }

    if (req.method === "POST" && url.pathname === "/api/reserve") {
      const body = await req.json();
      const { email, slot_id } = body;

      if (!email.match(/^[a-zA-Z0-9._%+-]+@univ-rouen\.fr$/)) {
        return new Response(
          JSON.stringify({ error: "Adresse email universitaire invalide." }),
          { status: 400, headers },
        );
      }

      const reservations = JSON.parse(readFileSync(RESERVATIONS_FILE, "utf-8"));

      if (reservations.some((r: any) => r.email === email)) {
        return new Response(
          JSON.stringify({ error: "Vous avez déjà effectué une réservation." }),
          { status: 409, headers },
        );
      }

      reservations.push({ email, slot_id, timestamp: Date.now() });
      writeFileSync(RESERVATIONS_FILE, JSON.stringify(reservations, null, 2));

      return new Response(
        JSON.stringify({ success: true, message: "Réservation confirmée." }),
        { headers },
      );
    }

    return new Response("Not Found", { status: 404, headers });
  },
});
