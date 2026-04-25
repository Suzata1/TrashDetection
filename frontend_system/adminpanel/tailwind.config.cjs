// tailwind.config.cjs
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './index.html',
    './src/**/*.{js,ts,jsx,tsx}', // <-- include all your React files
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}