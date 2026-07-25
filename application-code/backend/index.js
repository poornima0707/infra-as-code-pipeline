const express = require("express");
const cors = require("cors");

const app = express();

const PORT = process.env.PORT || 3500;

app.use(cors());
app.use(express.json());

/*
|--------------------------------------------------------------------------
| Health Check Endpoint
|--------------------------------------------------------------------------
| AWS Application Load Balancer uses this endpoint.
*/
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    service: "infra-as-code-pipeline-backend",
    environment: process.env.NODE_ENV || "dev",
    timestamp: new Date().toISOString()
  });
});

/*
|--------------------------------------------------------------------------
| Root Endpoint
|--------------------------------------------------------------------------
*/
app.get("/", (req, res) => {
  res.status(200).json({
    message: "Infrastructure as Code Pipeline Backend is running",
    status: "success"
  });
});

/*
|--------------------------------------------------------------------------
| Readiness Endpoint
|--------------------------------------------------------------------------
*/
app.get("/ready", (req, res) => {
  res.status(200).json({
    status: "ready"
  });
});

/*
|--------------------------------------------------------------------------
| Example API Endpoint
|--------------------------------------------------------------------------
*/
app.get("/api", (req, res) => {
  res.status(200).json({
    message: "API is working successfully"
  });
});

/*
|--------------------------------------------------------------------------
| Start Server
|--------------------------------------------------------------------------
*/
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Backend server running on port ${PORT}`);
});
