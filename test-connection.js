// Quick MongoDB connection test
require('dotenv').config();
const mongoose = require('mongoose');

async function testConnection() {
    try {
        console.log('Testing MongoDB connection...');
        console.log('Connection string:', process.env.MONGODB_URI.replace(/:[^:@]+@/, ':****@'));
        
        await mongoose.connect(process.env.MONGODB_URI, {
            serverSelectionTimeoutMS: 10000,
        });
        
        console.log('✅ Connection successful!');
        console.log('Database:', mongoose.connection.db.databaseName);
        console.log('Host:', mongoose.connection.host);
        
        // Test a simple operation
        const collections = await mongoose.connection.db.listCollections().toArray();
        console.log('Collections:', collections.map(c => c.name));
        
        await mongoose.disconnect();
        process.exit(0);
    } catch (error) {
        console.error('❌ Connection failed:', error.message);
        console.error('Error details:', {
            name: error.name,
            code: error.code,
        });
        
        if (error.reason && error.reason.servers) {
            console.error('\nServer connection status:');
            error.reason.servers.forEach((server, address) => {
                console.error(`  ${address}:`);
                console.error(`    - Type: ${server.type}`);
                console.error(`    - Error: ${server.error || 'None'}`);
                console.error(`    - RoundTripTime: ${server.roundTripTime || 'N/A'}ms`);
            });
        }
        
        console.error('\n💡 Possible issues:');
        console.error('1. Password might be incorrect');
        console.error('2. Database user might not have proper permissions');
        console.error('3. Try regenerating the connection string from Atlas');
        console.error('4. Verify the password in MongoDB Atlas Dashboard');
        
        process.exit(1);
    }
}

testConnection();

