-- 数据库迁移脚本
-- 添加 token_balance 字段
ALTER TABLE users ADD COLUMN token_balance FLOAT DEFAULT 0;

-- 添加累计充值和累计消费字段
ALTER TABLE users ADD COLUMN total_recharge FLOAT DEFAULT 0;
ALTER TABLE users ADD COLUMN total_consume FLOAT DEFAULT 0;

-- 添加订单类型字段
ALTER TABLE orders ADD COLUMN order_type VARCHAR(20) DEFAULT 'membership';
