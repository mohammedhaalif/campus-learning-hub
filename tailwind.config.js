/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        ink: '#14213d',
        brand: '#4f46e5',
        canvas: '#f5f7fb'
      },
      boxShadow: { soft: '0 12px 35px rgba(20,33,61,.07)' }
    }
  },
  plugins: []
}
