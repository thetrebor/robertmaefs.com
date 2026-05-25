// api.robertmaefs.com — Proxy contact form submissions to AWS API Gateway
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // Only handle POST to /contact
    if (request.method === 'POST' && url.pathname === '/contact') {
      const apiUrl = 'https://1g5x3kc611.execute-api.us-east-1.amazonaws.com/contact';

      // Forward the request
      const upstream = new Request(apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: request.body,
      });

      try {
        const response = await fetch(upstream);
        const data = await response.json();

        return new Response(JSON.stringify(data), {
          status: response.status,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': 'https://robertmaefs.com',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
          },
        });
      } catch (err) {
        return new Response(JSON.stringify({ error: 'Service unavailable' }), {
          status: 502,
          headers: { 'Content-Type': 'application/json' },
        });
      }
    }

    // Handle OPTIONS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: {
          'Access-Control-Allow-Origin': 'https://robertmaefs.com',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      });
    }

    return new Response('Not found', { status: 404 });
  },
};
