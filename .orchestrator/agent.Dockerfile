ARG AGENT_IMAGE
FROM ${AGENT_IMAGE}
USER root
# 轻量验证环境（重操作在 GitHub CI，容器里刻意不装 JDK/SDK/NDK/浏览器/Docker）：
#   haxe + haxelib(openfl/lime/swf/utest)：AS3→Haxe 翻译的编译验证（html5 目标）
#     和单元测试（eval 解释器），构建镜像时装好，任务运行时不再装。
#   php-cli：读懂并试跑 legacy/deploy 里的 PHP 片段（php -l / php -r）。
#   nodejs：checks/ 里的校验脚本。
# 注意：haxelib 未锁版本，首次 H1 跑通后把解析出的版本组（haxelib list）写进
# openfl-farm-docs 的决策页，并在此处和 .github/workflows/web.yml 显式锁同一组。
RUN apt-get update \
 && apt-get install -y --no-install-recommends haxe php-cli nodejs \
 && rm -rf /var/lib/apt/lists/* \
 && haxelib setup /usr/local/lib/haxelib \
 && haxelib install lime \
 && haxelib install openfl \
 && haxelib install swf \
 && haxelib install utest
USER agent
