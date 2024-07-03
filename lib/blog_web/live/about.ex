defmodule BlogWeb.About do
    use BlogWeb, :live_view
    require Logger
    alias Blog.Landing

    def mount(_params, _session, socket) do
      about = Landing.about()
      tags = Landing.all_tags()
      {:ok, assign(socket, active_nav: :about, about: about, tags: tags, page_title: "About Me")}
    end

    def render(assigns) do
      ~H"""
      <div class="about">
        <div id="header-section" class="grid md:grid-cols-2 gap-5 mt-10">
          <div class="">
            <img id="rishi-profile-photo" src="/images/hrishikesh-photo-linkedin.png" style="max-height: 38rem" alt="Hrishikesh Choudhari">
          </div>
          <h1 class="mt-20 text-black text-4xl font-snpro mb-10 text-center font-medium">
            Hrishikesh <br/>( <img src="/images/r-logo.png" class="inline-block max-h-9" alt="Rishi logo">ishi )<br/> Choudhari
          </h1>
        </div>
        <div class="mt-20">
          <ul>
            <li class="mb-1">
            <div class="flex flex-row">
                <div class="text-3xl w-36 text-teal-500 font-snpro font-medium tracking-tight">Code</div>
                <div class="flex-col h-5 w-full pl-1">
                  <div class="w-full h-1 bg-gradient-to-r from-teal-500 to-teal-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-teal-500 to-teal-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-teal-500 to-teal-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-teal-500 to-teal-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-teal-500 to-teal-950 mb-1 rounded-l-lg"></div>
                </div>
              </div>
            </li>
            <li class="mb-1">
              <div class="flex flex-row">
                <div class="text-3xl w-36 text-amber-600 font-snpro font-medium tracking-tight">People</div>
                <div class="flex-col h-5 w-full pl-1">
                  <div class="w-full h-1 bg-gradient-to-r from-amber-600 to-amber-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-amber-600 to-amber-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-amber-600 to-amber-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-amber-600 to-amber-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-amber-600 to-amber-950 mb-1 rounded-l-lg"></div>
                </div>
              </div>
            </li>

            <li class="mb-1">
            <div class="flex flex-row">
                <div class="text-3xl w-36 text-purple-600 font-snpro font-medium tracking-tight">Design</div>
                <div class="flex-col h-5 w-full pl-1">
                  <div class="w-full h-1 bg-gradient-to-r from-purple-600 to-purple-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-purple-600 to-purple-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-purple-600 to-purple-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-purple-600 to-purple-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-purple-600 to-purple-950 mb-1 rounded-l-lg"></div>
                </div>
              </div>
            </li>
            <li class="mb-16">
            <div class="flex flex-row">
                <div class="text-3xl w-36 text-sky-600 font-snpro font-medium tracking-tight">Process</div>
                <div class="flex-col h-5 w-full pl-1">
                  <div class="w-full h-1 bg-gradient-to-r from-sky-600 to-sky-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-sky-600 to-sky-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-sky-600 to-sky-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-sky-600 to-sky-950 mb-1 rounded-l-lg"></div>
                  <div class="w-full h-1 bg-gradient-to-r from-sky-600 to-sky-950 mb-1 rounded-l-lg"></div>
                </div>
              </div>
            </li>
          </ul>
          <h2 class="mt-10 text-black text-xl font-snpro mb-10">
          Skilled Operator at Product Management leading cross-functional teams to deliver products going from 0 to 1, and 1 to scale.
          <br/>
          <br/>
          With a hands-on approach, I excel in driving product vision and execution, from ideation, design & execution to GTM strategy.
          <br/>
          <br/>
          Experienced in complex SaaS offerings in cloud, analytics, and B2B environments.
          <br/>
          <br/>
          Skilled in engaging with internal stakeholders and enabling marketing & sales, I bring a unique blend of hands-on programming, UX design, product management and customer development.
        </h2>

          <h1 class="mt-10 text-black text-4xl font-snpro mb-10 text-center">
          Areas of Expertise
          </h1>
          <ul class="grid xs:grid-cols-2 xs:gap-2 md:grid-cols-3 md:gap-4 list-disc">
            <li>Cloud-native Product Strategy (AWS) </li>
            <li>Business Analytics & Data Platforms</li>
            <li>Modern Data Stack and Visualizations </li>
            <li>Service Design Thinking</li>
            <li>Technical Product Roadmaps</li>
            <li>SaaS & PaaS Lifecycle Management</li>
            <li>Customer Journey Mapping</li>
            <li>ProductOps & DevOps</li>
            <li>Lean Prototypal Iterations</li>
            <li>Voice-of-Customer Feedback Loops</li>
            <li>Data-driven Decision Making</li>
            <li>User Experience Architecture</li>
            <li>Stakeholder Engagement</li>
            <li>Competitive Analysis</li>
            <li>Innovation & Feature Ideation</li>
            <li>Product Risk Assessment & Mitigation</li>
            <li>CI / CD Environments</li>
            <li>Strategic Partnerships & Alliances</li>
            <li>Requirements documentation and traceability</li>
            <li>Lean & agile philosophy</li>
            <li>Behavioral Analytics</li>
            <li>Hands-on programming in JavaScript, TypeScript, SQL, Elixir, BDD</li>
          </ul>
        </div>
      </div>
      """
    end
end
