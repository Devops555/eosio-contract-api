const { createLogger, transports, format } = require('winston');

const defaultLevel = process.env.LOG_LEVEL || 'info';

const options = {
    exitOnError: false,
    level: defaultLevel,
    format: format.combine(
        format.metadata(),
        format.colorize(),
        format.timestamp(),
        format.printf((info: any) => {
            return `${info.timestamp} [PID:${process.pid}] [${info.level}] : ${info.message} ${Object.keys(info.metadata).length > 0 ? JSON.stringify(info.metadata) : ''}`;
        })
    )
};

const logger = new createLogger(options);

if (process.env.NODE_ENV === 'production') {
    logger.add(new transports.Console({
        colorize: true,
        showLevel: true,
        timestamp: true
    }));
} else {
    logger.add(new transports.Console({
        colorize: true,
        showLevel: true,
        timestamp: true,
        level: 'debug'
    }));
}

logger.add(new transports.File({ filename: '../logs/error.log', level: 'error' }));

export default logger;
