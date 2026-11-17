ARG AGENT_IMAGE
FROM ${AGENT_IMAGE}
USER root
# 轻量验证环境（重操作在 GitHub CI，容器里刻意不装 JDK/SDK/NDK/浏览器/Docker）：
#   haxe + haxelib(openfl/lime/swf/utest)：AS3→Haxe 翻译的编译验证（html5 目标）
#     和单元测试（eval 解释器），构建镜像时装好，任务运行时不再装。
#   php-cli：读懂并试跑 legacy/deploy 里的 PHP 片段（php -l / php -r）。
#   nodejs：checks/ 里的校验脚本。
# 版本组锁定（2026-11-16 CI 实测跑通；与 .github/workflows/{web,android}.yml 保持一致）：
#   lime 8.3.2 / openfl 9.5.2 / swf 3.4.0 / utest 1.13.2（容器只跑 html5 编译和 eval 单测，
#   不需要 libhxcpp——那是 android C++ 目标用的）
RUN apt-get update \
 && apt-get install -y --no-install-recommends haxe php-cli nodejs \
 && rm -rf /var/lib/apt/lists/* \
 && haxelib setup /usr/local/lib/haxelib \
 && haxelib install lime 8.3.2 \
 && haxelib install openfl 9.5.2 \
 && haxelib install swf 3.4.0 \
 && haxelib install utest 1.13.2
USER agent
