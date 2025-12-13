import { PrismaClient } from "@prisma/client"

const prisma = new PrismaClient();

async function main() {
  console.log('--- Start Test ---');

  const user = await prisma.users.create({
    data: {
      first_name: 'Test',
      last_name: 'Test',
      email: `test${Date.now()}@test.com`,
      phone: `+380${Date.now()}`,
    },
  });
  console.log('1. User created:', user.id);

  const category = await prisma.categories.create({
    data: { name: `Electronics-${Date.now()}` },
  });

  const seller = await prisma.seller_profiles.create({
    data: {
      user_id: user.id,
      store_name: 'Test',
      rating: 5.0
    }
  });
  console.log('2. Seller Profile created with Rating:', seller.rating);

  const product = await prisma.products.create({
    data: {
      name: 'iPhone 15',
      price: 999.99,
      stock_quantity: 5,
      owner_id: seller.id,
      category_id: category.id,
    },
  });

  await prisma.wishlist.create({
    data: {
      user_id: user.id,
      product_id: product.id
    }
  });
  console.log('3. Added to Wishlist successfully!');

  const address = await prisma.user_addresses.create({
    data: {
      user_id: user.id,
      country: 'Ukraine',
      city: 'Kyiv',
      street: 'Khreshchatyk',
      house_number: '1',
      postal_code: '01001'
    }
  });

  const order = await prisma.orders.create({
    data: {
      user_id: user.id,
      shipping_address_id: address.id,
      status: 'NEW'
    }
  });

  const shipment = await prisma.shipments.create({
    data: {
      order_id: order.id,
      method: 'COURIER',
      status: 'PENDING',
      // tracking_number: 'TR123456'
    }
  });
  console.log('4. Shipment created without tracking_number:', shipment);

  console.log('--- Test Completed Successfully ---');
}

main()
  .catch(e => console.error(e))
  .finally(async () => await prisma.$disconnect());