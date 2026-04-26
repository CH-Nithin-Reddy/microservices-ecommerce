const express = require('express');
const app = express();
app.use(express.json());

let orders = [
  { id: 1, userId: 1, productId: 2, quantity: 1 },
  { id: 2, userId: 2, productId: 1, quantity: 2 }
];

app.get('/orders', (req, res) => {
  res.json(orders);
});

app.get('/orders/:id', (req, res) => {
  const order = orders.find(o => o.id === parseInt(req.params.id));
  if (order) {
    res.json(order);
  } else {
    res.status(404).json({ error: 'Order not found' });
  }
});

app.post('/orders', (req, res) => {
  const newOrder = { id: orders.length + 1, ...req.body };
  orders.push(newOrder);
  res.status(201).json(newOrder);
});

app.listen(3003, () => {
  console.log('Orders service running on port 3003');
});