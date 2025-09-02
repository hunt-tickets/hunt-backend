// Simple utility functions
export function sayHello(): string {
  return 'Hello from Hunt Tickets!';
}

export function getCurrentTime(): string {
  return new Date().toISOString();
}

export function generateTestData(): any {
  return {
    id: Math.floor(Math.random() * 1000),
    name: 'Test Event',
    created: getCurrentTime()
  };
}