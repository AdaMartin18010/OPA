module.exports = {
  // 站点配置
  title: 'OPA 技术文档',
  description: 'Open Policy Agent - 全面技术分析与实践指南',
  base: '/OPA/',
  
  // 主题配置
  themeConfig: {
    // 导航栏
    nav: [
      { text: '首页', link: '/' },
      { text: '快速开始', link: '/QUICK_REFERENCE' },
      { text: 'FAQ', link: '/FAQ' },
      { text: '学习路径', link: '/LEARNING_PATH' },
      { text: '术语表', link: '/GLOSSARY' },
      { 
        text: '代码示例', 
        link: '/examples/',
        items: [
          { text: 'Hello World', link: '/examples/01-hello-world/' },
          { text: 'RBAC权限', link: '/examples/02-basic-rbac/' },
          { text: 'K8s准入', link: '/examples/03-kubernetes-admission/' },
          { text: '性能优化', link: '/examples/04-performance-optimization/' },
          { text: 'Envoy集成', link: '/examples/05-envoy-authz/' },
          { text: '数据过滤', link: '/examples/06-data-filtering/' }
        ]
      },
      { text: 'GitHub', link: 'https://github.com/AdaMartin18010/OPA' }
    ],
    
    // 侧边栏
    sidebar: {
      '/': [
        {
          title: '📖 总览',
          collapsable: false,
          children: [
            '',
            '00-总览与索引'
          ]
        },
        {
          title: '🔧 技术规范',
          collapsable: true,
          children: [
            '01-技术规范/01.1-API规范',
            '01-技术规范/01.2-Bundle格式规范',
            '01-技术规范/01.3-WASM编译规范',
            '01-技术规范/01.4-性能基准与度量',
            '01-技术规范/01.5-安全合规标准'
          ]
        },
        {
          title: '📖 语言模型',
          collapsable: true,
          children: [
            '02-语言模型/02.1-Rego语法规范',
            '02-语言模型/02.2-类型系统',
            '02-语言模型/02.3-内置函数库',
            '02-语言模型/02.4-求值模型'
          ]
        },
        {
          title: '⚙️ 实现架构',
          collapsable: true,
          children: [
            '03-实现架构/03.1-词法分析与语法解析',
            '03-实现架构/03.2-AST与IR',
            '03-实现架构/03.3-编译器设计',
            '03-实现架构/03.4-Top-Down求值器',
            '03-实现架构/03.5-索引与优化',
            '03-实现架构/03.6-部分求值技术'
          ]
        },
        {
          title: '🌐 生态系统',
          collapsable: true,
          children: [
            '04-生态系统/04.1-Kubernetes集成',
            '04-生态系统/04.2-Gatekeeper详解'
          ]
        },
        {
          title: '💼 应用场景',
          collapsable: true,
          children: [
            '05-应用场景/05.1-访问控制(RBAC)',
            '05-应用场景/05.2-API网关授权'
          ]
        },
        {
          title: '🎓 形式化证明',
          collapsable: true,
          children: [
            '06-形式化证明/06.1-Datalog理论基础',
            '06-形式化证明/06.2-Rego形式化语义',
            '06-形式化证明/06.3-命题逻辑与一阶逻辑基础',
            '06-形式化证明/06.4-求值算法正确性证明',
            '06-形式化证明/06.5-类型系统形式化',
            '06-形式化证明/06.6-部分求值理论',
            '06-形式化证明/06.7-抽象解释理论',
            '06-形式化证明/06.8-并发语义与正确性'
          ]
        },
        {
          title: '🗺️ 概念图谱',
          collapsable: true,
          children: [
            '07-概念图谱/07.1-核心概念定义'
          ]
        },
        {
          title: '💡 最佳实践',
          collapsable: true,
          children: [
            '08-最佳实践/08.1-策略设计模式',
            '08-最佳实践/08.2-性能优化指南'
          ]
        },
        {
          title: '🏭 生产实战',
          collapsable: true,
          children: [
            '09-生产实战/09.1-电商API授权实战',
            '09-生产实战/09.2-金融K8s策略实战',
            '09-生产实战/09.3-SaaS多租户WASM实战'
          ]
        },
        {
          title: '🔍 源码分析',
          collapsable: true,
          children: [
            '10-源码分析/10.1-OPA架构总览与代码结构',
            '10-源码分析/10.2-词法器与语法解析器实现',
            '10-源码分析/10.3-AST构建与转换',
            '10-源码分析/10.4-编译器实现详解',
            '10-源码分析/10.5-Top-Down求值器源码',
            '10-源码分析/10.6-内置函数实现机制',
            '10-源码分析/10.7-索引系统实现',
            '10-源码分析/10.8-部分求值引擎',
            '10-源码分析/10.9-Bundle管理实现',
            '10-源码分析/10.10-决策日志系统'
          ]
        },
        {
          title: '🧮 算法深度',
          collapsable: true,
          children: [
            '11-算法深度/11.1-SLD-Resolution详解',
            '11-算法深度/11.2-Robinson统一算法',
            '11-算法深度/11.3-索引数据结构',
            '11-算法深度/11.4-查询优化算法',
            '11-算法深度/11.5-并发控制机制'
          ]
        },
        {
          title: '📚 理论实践',
          collapsable: true,
          children: [
            '12-理论实践/12.1-类型安全策略开发',
            '12-理论实践/12.2-性能剖析实战',
            '12-理论实践/12.3-大规模部署架构',
            '12-理论实践/12.4-安全加固实践',
            '12-理论实践/12.5-CI_CD最佳实践',
            '12-理论实践/12.6-CVE-2025-46569安全通告'
          ]
        },
        {
          title: '🎯 工具与资源',
          collapsable: true,
          children: [
            'QUICK_REFERENCE',
            'FAQ',
            'LEARNING_PATH',
            'GLOSSARY',
            'VERSION_COMPATIBILITY',
            'PRODUCTION_CASES',
            'CHECKLIST',
            'CHANGELOG',
            'CONTRIBUTING',
            'CONTRIBUTORS',
            'DEPLOYMENT',
            'DEPLOYMENT_PROGRESS',
            'DEPLOYMENT_STATUS',
            'FINAL_DEPLOYMENT_GUIDE',
            'IMPROVEMENT_PLAN',
            'OPTIMIZATION_SUMMARY',
            'PHASE1_COMPLETION_REPORT',
            'PHASE3_COMPLETION_REPORT',
            'PHASE4_COMPLETION_REPORT',
            'PROGRESS_REPORT_2025-10-21',
            'PROGRESS_UPDATE_2025-10-21-P2',
            'PROGRESS_UPDATE_2025-10-21-P3',
            'PROGRESS_UPDATE_2025-10-25',
            'PROJECT_ACHIEVEMENT',
            'PROJECT_COMPLETE',
            'PROJECT_COMPLETION_REPORT',
            'PROJECT_COMPLETION_SUMMARY',
            'PROJECT_DASHBOARD',
            'PROJECT_FINAL_STATUS',
            'PROJECT_FINAL_SUMMARY',
            'PROJECT_INDEX',
            'PROJECT_REVIEW',
            'PROJECT_STATUS',
            'PROJECT_SUCCESS',
            'PROJECT_SUMMARY',
            'RELEASE_v2.4',
            'ROADMAP',
            'V2.5.0_RELEASE_NOTES',
            'V2.5.0_SUMMARY',
            'V2.6.0_RELEASE_NOTES'
          ]
        }
      ],
      
      '/examples/': [
        {
          title: '🧪 代码示例',
          collapsable: false,
          children: [
            '',
            '01-hello-world/',
            '02-basic-rbac/',
            '03-kubernetes-admission/',
            '04-performance-optimization/',
            '05-envoy-authz/',
            '06-data-filtering/'
          ]
        }
      ]
    },
    
    // 搜索
    search: true,
    searchMaxSuggestions: 10,
    
    // 最后更新时间
    lastUpdated: '最后更新',
    
    // 编辑链接
    editLinks: true,
    editLinkText: '在 GitHub 上编辑此页',
    repo: 'AdaMartin18010/OPA',
    repoLabel: 'GitHub',
    docsRepo: 'AdaMartin18010/OPA',
    docsDir: 'docs',
    docsBranch: 'main',
    
    // 平滑滚动
    smoothScroll: true
  },
  
  // Markdown配置
  markdown: {
    lineNumbers: true,
    extractHeaders: ['h2', 'h3', 'h4'],
    toc: {
      includeLevel: [2, 3, 4]
    }
  },
  
  // 插件
  plugins: [
    '@vuepress/back-to-top',
    '@vuepress/medium-zoom',
    '@vuepress/nprogress',
    [
      '@vuepress/pwa',
      {
        serviceWorker: true,
        updatePopup: {
          message: "发现新内容可用",
          buttonText: "刷新"
        }
      }
    ],
    [
      '@vuepress/search',
      {
        searchMaxSuggestions: 10
      }
    ],
    [
      'vuepress-plugin-code-copy',
      {
        align: 'bottom',
        color: '#3eaf7c',
        successText: '已复制'
      }
    ],
    // SEO插件
    [
      'seo',
      {
        siteTitle: (_, $site) => $site.title,
        title: $page => $page.title,
        description: $page => $page.frontmatter.description || '全面深入的OPA技术文档 v2.6.0',
        author: (_, $site) => $site.themeConfig.author || 'OPA技术文档项目',
        tags: $page => $page.frontmatter.tags || ['OPA', 'Rego', 'Policy as Code'],
        twitterCard: _ => 'summary_large_image',
        type: $page => 'article',
        url: (_, $site, path) => ($site.themeConfig.domain || '') + path,
        image: ($page, $site) => $page.frontmatter.image || ($site.themeConfig.domain || '') + '/og-image.png',
        publishedAt: $page => $page.frontmatter.date && new Date($page.frontmatter.date),
        modifiedAt: $page => $page.lastUpdated && new Date($page.lastUpdated)
      }
    ],
    // 站点地图
    [
      'sitemap',
      {
        hostname: 'https://adamartin18010.github.io/OPA/',
        exclude: ['/404.html'],
        dateFormatter: time => {
          return new Date(time).toISOString()
        }
      }
    ],
    // 自动生成侧边栏
    [
      'vuepress-plugin-auto-sidebar',
      {
        titleMode: 'titlecase',
        collapsable: true
      }
    ]
  ],
  
  // 构建配置
  dest: 'dist',
  
  // 额外的配置
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['meta', { name: 'author', content: 'OPA技术文档项目' }],
    ['meta', { name: 'keywords', content: 'OPA,Open Policy Agent,Rego,策略引擎,RBAC,Kubernetes,技术文档,Policy as Code,云原生,Gatekeeper,v2.6.0' }],
    ['meta', { name: 'viewport', content: 'width=device-width,initial-scale=1,user-scalable=no' }],
    // SEO优化
    ['meta', { name: 'description', content: 'OPA(Open Policy Agent)全面技术文档 v2.6.0：涵盖Rego语法、Kubernetes集成、RBAC授权、性能优化、源码分析、算法深度等，包含形式化证明与生产实战案例' }],
    ['meta', { property: 'og:title', content: 'OPA技术文档 v2.6.0 - Open Policy Agent全面指南' }],
    ['meta', { property: 'og:description', content: '中文社区最全面的OPA技术文档，40万字深度内容，10+源码分析，算法深度解析，形式化证明，生产就绪' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:url', content: 'https://adamartin18010.github.io/OPA/' }],
    ['meta', { property: 'og:locale', content: 'zh_CN' }],
    ['meta', { property: 'og:version', content: 'v2.6.0' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:title', content: 'OPA技术文档 v2.6.0 - 全面实践指南' }],
    ['meta', { name: 'twitter:description', content: '涵盖理论、架构、源码、算法、实践的完整OPA文档体系' }],
    // 语言标记
    ['meta', { httpEquiv: 'content-language', content: 'zh-CN' }],
    ['link', { rel: 'alternate', hreflang: 'zh-CN', href: 'https://adamartin18010.github.io/OPA/' }],
    // 版本信息
    ['meta', { name: 'version', content: 'v2.6.0' }],
    // Google Analytics 4
    ['script', { async: true, src: 'https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX' }],
    ['script', {}, `
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'G-XXXXXXXXXX', {
        'send_page_view': true,
        'cookie_flags': 'SameSite=None;Secure'
      });
    `]
  ]
};
