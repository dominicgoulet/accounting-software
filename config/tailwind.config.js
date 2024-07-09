const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      keyframes: {
        'from-top-in-out-keyframes': {
            '0%': {
              transform: 'translateY(10%)',
              transform: 'translateX(10%)',
              opacity: 0,
            },
            '8%, 92%': {
              transform: 'translateY(0)',
              transform: 'translateX(0)',
              opacity: 1
            },
            '100%': {
              opacity: 0
            },
        },
        'fade-in-keyframes': {
            '0%': {
              opacity: 0,
            },
            '100%': {
              opacity: 1,
            },
        },
        'fade-out-keyframes': {
            '0%': {
              opacity: 1,
            },
            '100%': {
              opacity: 0,
            },
        },
        'pulse-keyframes': {
            '0%': { transform: 'scale(1)' },
            '50%': { transform: 'scale(1.05)' },
            '100%': { transform: 'scale(1)' },
        },
        'dropdown-open-frames': {
            '0%': {
              opacity: 0,
              transform: 'scaleX(.95)'
            },
            '100%': {
              opacity: 1,
              transform: 'scaleX(1)',
            },
        },
        'dropdown-close-frames': {
            '0%': {
              opacity: 1,
              transform: 'scale(1)'
            },
            '100%': {
              opacity: 0,
              transform: 'scale(.95)'
            },
        },
        'confirm-open-confirm-dialog-frames': {
            '0%': {
              opacity: 0,
              transform: 'translateY(10%)'
            },
            '100%': {
              opacity: 1,
              transform: 'translateY(0)'
            },
        },
        'confirm-close-confirm-dialog-frames': {
            '0%': {
              opacity: 1,
              transform: 'translateY(0)'
            },
            '100%': {
              opacity: 0,
              transform: 'translateY(10%)'
            },
        },
      },
      animation: {
        'flash': 'from-top-in-out-keyframes 2s both',
        'turbo-remove': 'fade-out-keyframes 1s both',
        'turbo-prepend': 'fade-in-keyframes .5s both',
        'turbo-replace': 'pulse-keyframes .5s both',
        'turbo-update': 'pulse-keyframes .5s both',
        'dropdown-open': 'dropdown-open-frames .1s ease-out',
        'dropdown-close': 'dropdown-close-frames .075s ease-in',
        'fade-in': 'fade-in-keyframes .3s ease-out',
        'fade-out': 'fade-out-keyframes .2s ease-in',
        'confirm-open-confirm-dialog': 'confirm-open-confirm-dialog-frames .3s ease-out',
        'confirm-close-confirm-dialog': 'confirm-close-confirm-dialog-frames .2s ease-in',
      }
    },
  },
  plugins: [
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
  ]
}

