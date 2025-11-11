import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

const app = express();
app.use(cors());
app.use(bodyParser.json());

const users = [{ email: "admin@demo.com", password: "$2b$10$5s7LX/Fixgms0w9KndZzPeyCRlVL0cE7HZm5Kq5kPah1yHbP1s8WS" }]; // password: admin123

app.get("/", (req, res) => res.json({ message: "Demondyctal Panel API Running ✅" }));

app.post("/login", async (req, res) => {
  const { email, password } = req.body;
  const user = users.find(u => u.email === email);
  if (!user) return res.status(401).json({ error: "Invalid credentials" });
  const valid = await bcrypt.compare(password, user.password);
  if (!valid) return res.status(401).json({ error: "Invalid credentials" });
  const token = jwt.sign({ email }, "demondyctal_secret", { expiresIn: "2h" });
  res.json({ token });
});

app.listen(8080, () => console.log("✅ Demondyctal Panel running on port 8080"));
