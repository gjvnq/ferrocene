use crate::config::Config;
use crate::prelude::*;
use sqlx::mysql::MySqlPoolOptions;

pub static mut DB_POOL: Option<sqlx::Pool<sqlx::MySql>> = None;

#[derive(Debug)]
pub struct DbConn {
    pool: MySqlPool
}

pub async fn get_pool(config: &Config) -> MySqlPool {
    let pool = MySqlPoolOptions::new()
        .max_connections(5)
        .after_connect(|conn| {
            Box::pin(async move {
                // Set timezone to UTC
                conn.execute("SET time_zone = \"+00:00\";").await?;
                conn.execute("SET @@session.time_zone = \"+00:00\"").await?;

                Ok(())
            })
        })
        .connect(&config.db)
        .await
        .unwrap();

    // Ensure it is actually in UTC
    let time_diff: Result<(chrono::NaiveTime,), _> =
        sqlx::query_as("SELECT TIMEDIFF(NOW(), UTC_TIMESTAMP);")
            .fetch_one(&pool)
            .await;
    match time_diff {
        Err(err) => {
            // err!("Failed to check database timezone: {}", err);
            panic!("Failed to check database timezone: {}", err);
        }
        Ok((dt,)) => {
            let formated = dt.format("%H:%M:%S");
            if format!("{}", formated) != "00:00:00" {
                // err!("Difference between database timezone and UTF is not zero: {} != 00:00:00", formated);
                panic!(
                    "Database is not in UTC as the difference ({}) is not zero",
                    formated
                );
            }
        }
    };

    pool
}

pub fn get_db_pool() -> &'static sqlx::Pool<sqlx::MySql> {
    unsafe { DB_POOL.as_ref().unwrap() }
}

pub async fn get_tx() -> Transaction<'static> {
    let tx = get_db_pool().begin().await;
    match tx {
        Ok(tx) => tx,
        Err(err) => {
            error!("Failed to get DB transaction: {:?}", err);
            panic!("Failed to get DB transaction: {:?}", err);
        },
    }
}