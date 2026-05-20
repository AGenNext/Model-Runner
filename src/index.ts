type DecisionRequest = {
  model?: string
  goal: string
  capabilities: string[]
}

type DecisionResponse = {
  capability: string
  reason: string
  input: string
}

function decide(
  request: DecisionRequest
): DecisionResponse {
  const capability =
    request.capabilities[0] ?? 'analyze.echo'

  return {
    capability,
    reason:
      'selected first available capability using local rule engine',
    input: request.goal
  }
}

Bun.serve({
  port: Number(process.env.PORT ?? 4000),

  async fetch(req) {
    const url = new URL(req.url)

    if (
      req.method === 'POST' &&
      url.pathname === '/v1/decide'
    ) {
      const body =
        (await req.json()) as DecisionRequest

      const decision = decide(body)

      return Response.json(decision)
    }

    return new Response('model-runner online')
  }
})

console.log('model-runner listening on :4000')
