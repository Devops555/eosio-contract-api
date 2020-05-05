import * as Redis from 'ioredis';

export default class RedisConnection {
    readonly conn: Redis.Redis;

    constructor(readonly prefix: string, host: string, port: number) {
        this.conn = new Redis({ host, port });
    }
}
