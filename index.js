const Fastify = require('fastify');
const { LlamaCpp } = require('@withcatai/llama-cpp-node'); // 👈 updated import
const fastify = Fastify();

const modelPath = process.env.MODEL_PATH + '/ggml-model.bin'; // Path to your model

async function main() {
  const llama = new LlamaCpp({ model: modelPath });

  fastify.post('/generate', async (request, reply) => {
    const { prompt } = request.body;
    const output = llama.predict(prompt, {
      n_predict: 256,
      top_k: 40,
      top_p: 0.9,
      temperature: 0.8,
    });
    reply.send({ text: output });
  });

  fastify.listen({ port: 8000, host: '0.0.0.0' }, (err, address) => {
    if (err) throw err;
    console.log(`Server running at ${address}`);
  });
}

main();
