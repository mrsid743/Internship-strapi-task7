import path from 'path';

export default ({ env }) => {
  // =================================================
  // Production (PostgreSQL) Environment
  // =================================================
  if (env('NODE_ENV') === 'production') {
    return {
      connection: {
        client: 'postgres',
        connection: {
          host: env('DATABASE_HOST'),
          port: env.int('DATABASE_PORT', 5432),
          database: env('DATABASE_NAME'),
          user: env('DATABASE_USERNAME'),
          password: env('DATABASE_PASSWORD'),
          // --- THIS IS THE FINAL FIX ---
          // Force SSL connection to the database
          ssl: { rejectUnauthorized: false },
        },
        debug: false,
      },
    };
  }

  // =================================================
  // Development (SQLite) Environment
  // =================================================
  return {
    connection: {
      client: 'sqlite',
      connection: {
        filename: path.join(__dirname, '..', '..', '.tmp/data.db'),
      },
      useNullAsDefault: true,
    },
  };
};