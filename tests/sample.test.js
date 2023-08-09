const { add } = require('./sample');

test('should add two numbers', () => {
    expect(add(2, 3)).toBe(5);
});
