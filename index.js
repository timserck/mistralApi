import Fastify from "fastify";
import { getLlama, LlamaChatSession, LlamaModel, LlamaContext } from "node-llama-cpp";

const fastify = Fastify();

const modelPath = process.env.MODEL_PATH + "/ggml-model.bin"; // Path to your model

async function main() {
  // Initialize Llama.cpp
  const llama = await getLlama();

  // Load model
  const model = new LlamaModel({
    modelPath,
  });

  // Create context (used for inference)
  const context = new LlamaContext({ model });

  // Create a chat session (optional, good for multiple prompts)
  const session = new LlamaChatSession({ context });

  // POST endpoint for text generation
  fastify.post("/generate", async (request, reply) => {
    const { prompt } = request.body;

    // Generate text
    const output = await session.prompt(prompt, {
      temperature: 0.8,
      topK: 40,
      topP: 0.9,
      nPredict: 256,
    });

    reply.send({ text: output });
  });

  // Start the Fastify server
  fastify.listen({ port: 8000, host: "0.0.0.0" }, (err, address) => {
    if (err) throw err;
    console.log(`✅ Server running at ${address}`);
  });
}

main().catch(console.error);
