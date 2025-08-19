// Simple test file
import { sayHello, generateTestData } from './lib/simple.ts';
import { getConfig } from './config/settings.ts';

export function runTest(): any {
  return {
    message: sayHello(),
    config: getConfig('VERSION'),
    maxTickets: getConfig('MAX_TICKETS_PER_REQUEST'),
    testData: generateTestData(),
    success: true
  };
}