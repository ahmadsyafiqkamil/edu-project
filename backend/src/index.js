require("dotenv").config();
const express = require("express");

const app = express();

app.use(express.json());
const userModule = require("./modules/users/users");

app.use("/users", userModule);

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
