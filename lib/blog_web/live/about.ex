defmodule BlogWeb.About do
    use BlogWeb, :live_view
    require Logger
    alias Blog.Landing

    def mount(_params, _session, socket) do
      page = Landing.get_page("about")
      tags = Landing.all_tags()
      {:ok, assign(socket, active_nav: :about, page: page, tags: tags, page_title: page.title || "About Me")}
    end

    def render(assigns) do
      ~H"""
      <%= if @page && @page.content != "" do %>
        <!-- Render custom content from database -->
        <div class="about-custom">
          <%= raw @page.content %>
        </div>
      <% else %>
        <!-- Default About Page with animations -->
        <div class="about" phx-hook="AboutAnimations" id="about-page">
          <!-- Hero Section with parallax -->
          <div id="header-section" class="relative min-h-screen flex items-center justify-center overflow-hidden">
            <!-- Animated background -->
            <div class="absolute inset-0 bg-gradient-to-br from-lava/10 via-transparent to-sacramento/10 animate-gradient"></div>
            
            <div class="relative z-10 grid md:grid-cols-2 gap-8 max-w-6xl mx-auto px-4">
              <div class="fade-in-up animation-delay-200">
                <img 
                  id="rishi-profile-photo" 
                  src="/images/hrishikesh-photo-linkedin.png" 
                  class="rounded-2xl shadow-2xl max-h-[32rem] w-full object-cover hover:scale-105 transition-transform duration-500" 
                  alt="Hrishikesh Choudhari"
                />
              </div>
              <div class="flex flex-col justify-center text-center md:text-left fade-in-up animation-delay-400">
                <h1 class="text-5xl md:text-6xl font-bold font-snpro mb-6 text-neutral-850">
                  Hrishikesh
                </h1>
                <div class="flex items-center justify-center md:justify-start mb-6">
                  <span class="text-3xl text-neutral-600 mr-2">(</span>
                  <img src="/images/r-logo.png" class="h-10 animate-bounce-slow" alt="Rishi logo">
                  <span class="text-3xl font-bold text-lava ml-1">ishi</span>
                  <span class="text-3xl text-neutral-600 ml-2">)</span>
                </div>
                <h2 class="text-3xl font-snpro text-neutral-850">Choudhari</h2>
                <p class="mt-6 text-xl text-neutral-600">
                  Product Leader • Engineer • Designer
                </p>
              </div>
            </div>
          </div>

          <!-- Skills visualization - Original style with multiple lines -->
          <div class="mt-20 max-w-4xl mx-auto px-4">
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
          </div>

          <!-- Bio Section -->
          <div class="mt-20 max-w-4xl mx-auto px-4 fade-in-up">
            <div class="bg-white rounded-2xl shadow-xl p-8 border-2 border-chiffon-200">
              <h2 class="text-2xl font-bold mb-6 text-neutral-850">About Me</h2>
              <div class="prose prose-lg max-w-none text-neutral-700">
                <p>
                  Skilled Operator at Product Management leading cross-functional teams to deliver products going from 0 to 1, and 1 to scale.
                </p>
                <p>
                  With a hands-on approach, I excel in driving product vision and execution, from ideation, design & execution to GTM strategy.
                </p>
                <p>
                  Experienced in complex SaaS offerings in cloud, analytics, and B2B environments.
                </p>
                <p>
                  Skilled in engaging with internal stakeholders and enabling marketing & sales, I bring a unique blend of hands-on programming, UX design, product management and customer development.
                </p>
              </div>
            </div>
          </div>

          <!-- Timeline of Achievements -->
          <div class="mt-20 max-w-4xl mx-auto px-4">
            <h2 class="text-3xl font-bold text-center mb-12 fade-in-up">Journey & Achievements</h2>
            <div class="timeline">
              <div class="timeline-item fade-in-up animation-delay-200">
                <div class="timeline-marker"></div>
                <div class="timeline-content">
                  <h3 class="font-bold text-xl mb-2">GRC Pulse Award</h3>
                  <p class="text-neutral-600">Excellence in Governance, Risk & Compliance solutions</p>
                </div>
              </div>
              
              <div class="timeline-item fade-in-up animation-delay-400">
                <div class="timeline-marker"></div>
                <div class="timeline-content">
                  <h3 class="font-bold text-xl mb-2">Intel Atom Innovation</h3>
                  <p class="text-neutral-600">Contributed to next-generation processor development</p>
                </div>
              </div>
              
              <div class="timeline-item fade-in-up animation-delay-600">
                <div class="timeline-marker"></div>
                <div class="timeline-content">
                  <h3 class="font-bold text-xl mb-2">Academic Excellence</h3>
                  <p class="text-neutral-600">Dean's List & President's List awards • MSc Thesis: Vectora.app</p>
                </div>
              </div>
              
              <div class="timeline-item fade-in-up animation-delay-800">
                <div class="timeline-marker"></div>
                <div class="timeline-content">
                  <h3 class="font-bold text-xl mb-2">American Society of Civil Engineers</h3>
                  <p class="text-neutral-600">Contributing member driving innovation in engineering</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Expertise Grid -->
          <div class="mt-20 max-w-6xl mx-auto px-4 mb-20">
            <h2 class="text-3xl font-bold text-center mb-12 fade-in-up">Areas of Expertise</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <%= for {skill, index} <- Enum.with_index([
                "Cloud-native Product Strategy (AWS)",
                "Business Analytics & Data Platforms",
                "Modern Data Stack and Visualizations",
                "Service Design Thinking",
                "Technical Product Roadmaps",
                "SaaS & PaaS Lifecycle Management",
                "Customer Journey Mapping",
                "ProductOps & DevOps",
                "Lean Prototypal Iterations",
                "Voice-of-Customer Feedback Loops",
                "Data-driven Decision Making",
                "User Experience Architecture",
                "Stakeholder Engagement",
                "Competitive Analysis",
                "Innovation & Feature Ideation",
                "Product Risk Assessment & Mitigation",
                "CI / CD Environments",
                "Strategic Partnerships & Alliances",
                "Requirements documentation and traceability",
                "Lean & agile philosophy",
                "Behavioral Analytics",
                "Hands-on programming in JavaScript, TypeScript, SQL, Elixir, BDD"
              ]) do %>
                <div class={"expertise-card fade-in-up animation-delay-#{rem(index, 4) * 200}"}>
                  <div class="bg-white rounded-lg p-4 shadow-md hover:shadow-xl transition-shadow duration-300 border border-neutral-200 hover:border-lava">
                    <p class="text-neutral-700"><%= skill %></p>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Custom CSS for animations -->
        <style>
          @keyframes fadeInUp {
            from {
              opacity: 0;
              transform: translateY(30px);
            }
            to {
              opacity: 1;
              transform: translateY(0);
            }
          }
          
          @keyframes fadeInLeft {
            from {
              opacity: 0;
              transform: translateX(-30px);
            }
            to {
              opacity: 1;
              transform: translateX(0);
            }
          }
          
          @keyframes gradient {
            0%, 100% { transform: rotate(0deg) scale(1); }
            50% { transform: rotate(180deg) scale(1.1); }
          }
          
          @keyframes bounceSlow {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
          }
          
          @keyframes skillFill {
            from { width: 0; }
            to { width: var(--fill-width); }
          }
          
          .fade-in-up {
            opacity: 0;
            animation: fadeInUp 0.8s ease-out forwards;
          }
          
          .fade-in-left {
            opacity: 0;
            animation: fadeInLeft 0.8s ease-out forwards;
          }
          
          .animation-delay-200 { animation-delay: 0.2s; }
          .animation-delay-400 { animation-delay: 0.4s; }
          .animation-delay-600 { animation-delay: 0.6s; }
          .animation-delay-800 { animation-delay: 0.8s; }
          
          .animate-gradient {
            animation: gradient 20s ease infinite;
          }
          
          .animate-bounce-slow {
            animation: bounceSlow 3s ease-in-out infinite;
          }
          
          .skill-fill {
            width: 0;
            animation: skillFill 1.5s ease-out forwards;
            animation-delay: inherit;
          }
          
          .timeline {
            position: relative;
            padding-left: 2rem;
          }
          
          .timeline::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 2px;
            background: linear-gradient(to bottom, #F56E0F, #047857);
          }
          
          .timeline-item {
            position: relative;
            padding-bottom: 2rem;
          }
          
          .timeline-marker {
            position: absolute;
            left: -2.5rem;
            top: 0.25rem;
            width: 1rem;
            height: 1rem;
            background: #F56E0F;
            border-radius: 50%;
            border: 3px solid white;
            box-shadow: 0 0 0 3px #F56E0F20;
          }
          
          .timeline-content {
            background: white;
            padding: 1.5rem;
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            border: 1px solid #e5e7eb;
          }
        </style>
      <% end %>
      """
    end
end
