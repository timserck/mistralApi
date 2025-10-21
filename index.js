import Fastify from "fastify";
import { getLlama, LlamaChatSession, LlamaModel, LlamaContext } from "node-llama-cpp";

const fastify = Fastify();
const modelPath = process.env.MODEL_PATH; // <- directly points to the GGUF file

async function main() {
  // Initialize Llama.cpp
  const llama = await getLlama();
  if (!llama) {
    console.error("❌ Failed to load LlamaCpp native library.");
    process.exit(1);
  }

  // Load model
  const model = new LlamaModel({ modelPath });

  // Create context for inference
  const context = new LlamaContext({ model });

  // Optional: chat session
  const session = new LlamaChatSession({ context });

  // POST endpoint
  fastify.post("/generate", async (request, reply) => {
    const { prompt } = request.body;

    try {
      const output = await session.prompt(prompt, {
        temperature: 0.8,
        topK: 40,
        topP: 0.9,
        nPredict: 256,
      });
      reply.send({ text: output });
    } catch (err) {
      reply.status(500).send({ error: err.message });
    }
  });

  // Start server
  await fastify.listen({ port: 8000, host: "0.0.0.0" });
  console.log("✅ Server running at port 8000");
}

main().catch(console.error);
