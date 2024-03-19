// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/blog_web.ex",
    "../lib/blog_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        'pine': {
          '50': '#f2f8ed',
          '100': '#e0f0d7',
          '200': '#c3e3b3',
          '300': '#9ecf87',
          '400': '#7cbb60',
          '500': '#5da042',
          '600': '#477e32',
          '700': '#38612a',
          '800': '#304e26',
          DEFAULT: '#294122',
          '950': '#13240f',
        },
        'tangerine': {
          '50': '#fff5ec',
          '100': '#ffe9d3',
          '200': '#ffd0a5',
          '300': '#ffae6d',
          '400': '#ff8032',
          '500': '#ff5d0a',
          DEFAULT: '#eb3d00',
          '700': '#cc2c02',
          '800': '#a1240b',
          '900': '#82200c',
          '950': '#460d04',
        },
        'chiffon': {
          '50': '#fff8ed',
          DEFAULT: '#ffedd2',
          '200': '#fed9aa',
          '300': '#fdbe74',
          '400': '#fb973c',
          '500': '#f97916',
          '600': '#ea5e0c',
          '700': '#c2460c',
          '800': '#9a3812',
          '900': '#7c3012',
          '950': '#431607',
        },
        'sacramento': {
          '50': '#f4f7f2',
          '100': '#e5ebe0',
          '200': '#cad7c3',
          '300': '#a4bb9a',
          '400': '#7a996e',
          '500': '#597b4e',
          '600': '#43613a',
          '700': '#344e2e',
          '800': '#2b3e27',
          '900': '#233420',
          DEFAULT: '#162114',
        },
        'salmon': {
          '50': '#fef5f2',
          '100': '#ffe8e1',
          '200': '#ffd5c8',
          DEFAULT: '#ffbba6',
          '400': '#fd8e6c',
          '500': '#f5693e',
          '600': '#e24e20',
          '700': '#be3e17',
          '800': '#9d3717',
          '900': '#82331a',
          '950': '#471708',
        },                        
      },
      fontFamily: {
        snpro: 'SNPro',
        calistoga: 'Calistoga'
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, {values})
    })
  ]
}
