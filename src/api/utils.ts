import { HTTPServer } from './server';
import logger from '../utils/winston';
import { Namespace } from 'socket.io';
import { NotificationData } from '../filler/notifier';

export async function getContractActionLogs(
    server: HTTPServer, contract: string, actions: string[], condition: {[key: string]: any},
    offset: number = 0, limit: number = 100, order: 'asc' | 'desc' = 'asc'
): Promise<Array<{log_id: number, name: string, data: any, txid: string, created_at_block: string, created_at_time: string}>> {
    const queryStr = 'SELECT global_sequence log_id, name, metadata "data", encode(txid::bytea, \'hex\') txid, created_at_block, created_at_time ' +
        'FROM contract_traces ' +
        'WHERE account = $1 AND name = ANY($2) AND metadata @> $3::jsonb ' +
        'ORDER BY global_sequence ' + (order === 'asc' ? 'ASC' : 'DESC') + ' LIMIT $4 OFFSET $5 ';

    const query = await server.query(queryStr, [contract, actions, JSON.stringify(condition), limit, offset]);
    const emptyCondition = Object.keys(condition).reduce((prev, curr) => ({...prev, [curr]: undefined}), {});

    return query.rows.map(row => ({
        ...row, data: JSON.parse(JSON.stringify({...row.data, ...emptyCondition}))
    }));
}

export function createSocketApiNamespace(server: HTTPServer, path: string): Namespace {
    const namespace = server.socket.io.of(path);

    namespace.on('connection', async (socket) => {
        logger.debug('socket transfer client connected');

        let verifiedConnection = false;
        if (!(await server.socket.reserveConnection(socket))) {
            socket.disconnect(true);
        } else {
            verifiedConnection = true;
        }

        socket.on('disconnect', async () => {
            if (verifiedConnection) {
                await server.socket.releaseConnection(socket);
            }
        });
    });

    return namespace;
}

export function extractNotificationIdentifiers(notifications: NotificationData[], key: string): string[] {
    const result = [];

    for (const notification of notifications) {
        let identifier: any = null;

        if (notification.type === 'delta') {
            // @ts-ignore
            identifier = notification.data.delta.value[key];
        }

        if (notification.type === 'trace' && notification.data.trace) {
            // @ts-ignore
            identifier = notification.data.trace.act.data[key];
        }

        if (identifier && result.indexOf(identifier) === -1) {
            result.push(identifier);
        }
    }

    return result;
}
