export enum LogLevel {
  DEBUG = 'DEBUG',
  INFO = 'INFO',
  WARN = 'WARN',
  ERROR = 'ERROR',
}

export type LoggerConfig = {
  level?: LogLevel;
  enableTimestamp?: boolean;
  enableColors?: boolean;
};

export class Logger {
  private prefix: string;
  private config: Required<LoggerConfig>;

  private static readonly DEFAULT_CONFIG: Required<LoggerConfig> = {
    level: LogLevel.INFO,
    enableTimestamp: true,
    enableColors: true,
  };

  private static readonly COLORS = {
    reset: '\x1B[0m',
    debug: '\x1B[36m', // Cyan
    info: '\x1B[32m', // Green
    warn: '\x1B[33m', // Yellow
    error: '\x1B[31m', // Red
    prefix: '\x1B[35m', // Magenta
  };

  constructor(prefix: string = 'APP', config: LoggerConfig = {}) {
    this.prefix = prefix;
    this.config = { ...Logger.DEFAULT_CONFIG, ...config };
  }

  /**
   * Create a new logger instance with a specific prefix
   */
  static create(prefix: string, config?: LoggerConfig): Logger {
    return new Logger(prefix, config);
  }

  /**
   * Update logger configuration
   */
  public configure(config: Partial<LoggerConfig>): void {
    this.config = { ...this.config, ...config };
  }

  /**
   * Set the log level
   */
  public setLevel(level: LogLevel): void {
    this.config.level = level;
  }

  /**
   * Log debug message
   */
  public debug(message: string, ...args: unknown[]): void {
    this.log(LogLevel.DEBUG, message, ...args);
  }

  /**
   * Log info message
   */
  public info(message: string, ...args: unknown[]): void {
    this.log(LogLevel.INFO, message, ...args);
  }

  /**
   * Log warning message
   */
  public warn(message: string, ...args: unknown[]): void {
    this.log(LogLevel.WARN, message, ...args);
  }

  /**
   * Log error message
   */
  public error(
    message: string,
    error?: Error | unknown,
    ...args: unknown[]
  ): void {
    if (error instanceof Error) {
      this.log(LogLevel.ERROR, message, error.message, error.stack, ...args);
    } else if (error) {
      this.log(LogLevel.ERROR, message, error, ...args);
    } else {
      this.log(LogLevel.ERROR, message, ...args);
    }
  }

  /**
   * Core logging method
   */
  private log(level: LogLevel, message: string, ...args: unknown[]): void {
    const timestamp = this.config.enableTimestamp ? this.getTimestamp() : '';
    const levelLabel = this.getLevelLabel(level);
    const coloredPrefix = this.config.enableColors
      ? `${Logger.COLORS.prefix}[${this.prefix}]${Logger.COLORS.reset}`
      : `[${this.prefix}]`;

    const coloredLevel = this.config.enableColors
      ? `${this.getColorForLevel(level)}${levelLabel}${Logger.COLORS.reset}`
      : levelLabel;

    const logMessage = [
      timestamp,
      coloredPrefix,
      coloredLevel,
      message,
      ...args,
    ]
      .filter(Boolean)
      .join(' ');

    this.output(level, logMessage);
  }

  /**
   * Output the log message to the appropriate console method
   */
  private output(level: LogLevel, message: string): void {
    switch (level) {
      case LogLevel.DEBUG:
        console.debug(message);
        break;
      case LogLevel.INFO:
        console.info(message);
        break;
      case LogLevel.WARN:
        console.warn(message);
        break;
      case LogLevel.ERROR:
        console.error(message);
        break;
      default:
        console.log(message);
    }
  }

  /**
   * Get timestamp string
   */
  private getTimestamp(): string {
    return new Date().toISOString();
  }

  /**
   * Get level label
   */
  private getLevelLabel(level: LogLevel): string {
    return level;
  }

  /**
   * Get color for log level
   */
  private getColorForLevel(level: LogLevel): string {
    switch (level) {
      case LogLevel.DEBUG:
        return Logger.COLORS.debug;
      case LogLevel.INFO:
        return Logger.COLORS.info;
      case LogLevel.WARN:
        return Logger.COLORS.warn;
      case LogLevel.ERROR:
        return Logger.COLORS.error;
      default:
        return Logger.COLORS.reset;
    }
  }

  /**
   * Create a child logger with a sub-prefix
   */
  public child(subPrefix: string): Logger {
    return new Logger(`${this.prefix}:${subPrefix}`, this.config);
  }
}
