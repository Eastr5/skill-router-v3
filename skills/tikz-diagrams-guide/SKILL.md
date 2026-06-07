---
name: "tikz-diagrams-guide"
description: "Create publication-quality scientific diagrams with TikZ in LaTeX (Transformer, MLP, 3D, Bayesian, commutative). Invoke when user wants TikZ, LaTeX diagrams, or 贝叶斯/算法流程图/数学交换图."
---

# TikZ Diagrams Guide
# TikZ Diagrams Guide

A skill for creating publication-quality scientific diagrams directly in LaTeX using the TikZ package. Covers basic drawing commands, flowcharts, neural network architectures, data flow diagrams, and integration with PGFplots for camera-ready figures.

## Environment & Tooling (this user's machine)

- **TeX engine**: MiKTeX 25.12 (pdflatex / xelatex / latexmk all available; `where pdflatex` works)
- **Chinese**: `ctex` package pre-installed — use `\usepackage{ctex}` freely
- **Useful packages pre-installed**: `pgfplots` (3D), `tikz-bayesnet` (概率图), `tikz-cd` (交换图), `smartdiagram`, `forest`, `algorithm2e`
- **Build helpers**: `pdflatex -interaction=nonstopmode` then `pdftoppm -r 300 -png` for preview
- **Standalone document class** preferred for single-figure files (auto-crop to content)
- **MCPs available**: `mcp_drawio-official_*` (mermaid/CSV → diagram), `mcp_latex-mcp-server_*` (limited — see notes)
- **Companion skill**: `figura` (in this same `.trae/skills/` folder) for the render→view→fix iteration loop and visual defect catalog
- **Read tool** can display PNG previews — always view the compiled output before declaring done

> **Note on latex-mcp-server MCP**: The `mcp_latex-mcp-server_compile_latex` and `mcp_latex-mcp-server_read_pdf` tools are currently PLACEHOLDERS (the MCP just runs `python -m http.server 8080`). **Do not call them — use `RunCommand` with `pdflatex` / `pdftoppm` instead.** Other latex-mcp-server tools (`list_tex_files`, `read_file`, `extract_bibliography`, `download_bibliography`) may also error with schema issues — fall back to Glob/Read/Write tools.

## Getting Started with TikZ

### Basic Setup

```latex
\documentclass[tikz, border=4pt]{standalone}
\usepackage{tikz}
\usepackage{ctex}                     % only if Chinese text needed
\usetikzlibrary{arrows.meta, positioning, shapes.geometric, calc, fit, backgrounds, shadows.blur}

\begin{document}
\begin{tikzpicture}
  % Your drawing commands here
\end{tikzpicture}
\end{document}
```

For multi-figure demos, use `\documentclass[11pt,a4paper]{article}` with `ctex` and wrap each diagram in `\begin{figure}[h] \centering ... \end{figure}`.

### Fundamental Drawing Commands

```latex
% Lines and shapes
\draw (0,0) -- (3,0) -- (3,2) -- cycle;          % Triangle
\draw[thick, ->] (0,0) -- (4,0);                  % Arrow
\draw[dashed, blue] (0,0) circle (1.5);            % Dashed circle
\filldraw[fill=gray!20, draw=black] (2,1) ellipse (1 and 0.5);

% Nodes (text labels with optional shapes)
\node[draw, rectangle, minimum width=2cm] (A) at (0,0) {Input};
\node[draw, circle] (B) at (3,0) {Process};
\draw[->] (A) -- (B);

% Relative positioning (requires positioning library)
\node[draw, rectangle] (C) [right=2cm of B] {Output};
\draw[->] (B) -- (C);
```

### Gotcha: math-mode subscripts in \foreach

`x_1` in text mode causes `Missing $ inserted`. In `\foreach` lists, wrap each value in `{$x_1$}`:

```latex
\foreach \i/\n in {0/{$x_1$}, 1/{$x_2$}, 2/{$x_3$}} {
  \node (n\i) at (\i*1.3, 0) {\n};
}
```

## Common Scientific Diagrams

### Flowcharts

```latex
\begin{tikzpicture}[
  block/.style={rectangle, draw, fill=blue!10, text width=5em,
                text centered, rounded corners, minimum height=3em},
  decision/.style={diamond, draw, fill=green!10, text width=4em,
                   text centered, inner sep=0pt, aspect=2},
  line/.style={draw, -Stealth}
]
  \node[block] (data) {Collect Data};
  \node[block, below=1cm of data] (clean) {Clean \& Preprocess};
  \node[decision, below=1cm of clean] (valid) {Valid?};
  \node[block, below=1cm of valid] (analyze) {Analyze};
  \node[block, right=2cm of valid] (fix) {Fix Issues};

  \path[line] (data) -- (clean);
  \path[line] (clean) -- (valid);
  \path[line] (valid) -- node[right] {Yes} (analyze);
  \path[line] (valid) -- node[above] {No} (fix);
  \path[line] (fix) |- (clean);
\end{tikzpicture}
```

### Neural Network Architecture (MLP)

```latex
\begin{tikzpicture}[
  neuron/.style={circle, draw, minimum size=0.8cm, fill=orange!20},
  layer/.style={rectangle, draw, dashed, inner sep=0.3cm}
]
  % Input layer
  \foreach \i in {1,2,3,4} {
    \node[neuron] (I\i) at (0, -\i*1.2) {};
  }
  % Hidden layer
  \foreach \j in {1,2,3} {
    \node[neuron, fill=blue!20] (H\j) at (3, -\j*1.2 - 0.6) {};
  }
  % Output layer
  \foreach \k in {1,2} {
    \node[neuron, fill=green!20] (O\k) at (6, -\k*1.2 - 1.2) {};
  }
  % Connections
  \foreach \i in {1,2,3,4} \foreach \j in {1,2,3} \draw[->] (I\i) -- (H\j);
  \foreach \j in {1,2,3}     \foreach \k in {1,2}   \draw[->] (H\j) -- (O\k);
\end{tikzpicture}
```

### Transformer Block (Multi-Head Self-Attention + residual + FFN)

```latex
\begin{tikzpicture}[
  emb/.style={rectangle, rounded corners=2pt, draw=blue!70, fill=blue!20,
              minimum width=1.2cm, minimum height=0.7cm, font=\footnotesize},
  attn/.style={rectangle, rounded corners=4pt, draw=orange!80, fill=orange!25,
               minimum width=2.6cm, minimum height=1.2cm, align=center, font=\small},
  ff/.style={rectangle, rounded corners=4pt, draw=green!70, fill=green!20,
             minimum width=2.6cm, minimum height=1cm, align=center, font=\small},
  grp/.style={rectangle, rounded corners=8pt, draw=black!30, dashed, inner sep=14pt}
]
  % Inputs
  \foreach \i/\n in {0/{$x_1$}, 1/{$x_2$}, 2/{$x_3$}, 3/{$x_4$}}{
    \node[emb] (e\i) at (\i*1.3, 0) {\n};
  }
  % Stack
  \node[attn] (mha) at (2.6, -2.2) {Multi-Head\\Self-Attention};
  \node[block, fill=gray!10] (add1) at (2.6, -3.6) {Add \& Norm};
  \node[ff] (ff) at (2.6, -5.0) {Feed Forward};
  \node[block, fill=gray!10] (add2) at (2.6, -6.4) {Add \& Norm};
  % Outputs
  \foreach \i/\n in {0/{$y_1$}, 1/{$y_2$}, 2/{$y_3$}, 3/{$y_4$}}{
    \node[emb] (o\i) at (\i*1.3, -7.8) {\n};
  }
  % Arrows + residual
  \foreach \i in {0,1,2,3}{
    \draw[->, >=Stealth] (e\i) -- (mha);
    \draw[->, >=Stealth] (mha) -- (add1);
    \draw[->, >=Stealth] (add1) -- (ff);
    \draw[->, >=Stealth] (ff) -- (add2);
    \draw[->, >=Stealth] (add2) -- (o\i);
  }
  \draw[->, >=Stealth, dashed, red] (0.0,0) -- (0.0,-3.6) -- (add1.west);
  \draw[->, >=Stealth, dashed, red] (0.0,-3.6) -- (0.0,-6.4) -- (add2.west);

  \begin{scope}[on background layer]
    \node[grp, fit=(mha)(add1), label=above:{\footnotesize Encoder Block}] {};
  \end{scope}
\end{tikzpicture}
```

### 3D Math Surface (pgfplots)

```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}
\begin{tikzpicture}
\begin{axis}[
  title={$z = \frac{\sin(\sqrt{x^2+y^2})}{\sqrt{x^2+y^2}}$},
  xlabel={$x$}, ylabel={$y$}, zlabel={$z$},
  domain=-8:8, y domain=-8:8, samples=40, samples y=40,
  colormap/viridis, view={45}{30},
  width=13cm, height=9cm, grid=major
]
\addplot3[surf, shader=interp, opacity=0.95, draw=black!30, line width=0.1pt]
  {sin(deg(sqrt(x^2+y^2)))/max(sqrt(x^2+y^2),0.001)};
\end{axis}
\end{tikzpicture}
```

### Bayesian Network (tikz-bayesnet)

```latex
\usetikzlibrary{bayesnet}
\begin{tikzpicture}[
  latent/.style={circle, draw=blue, fill=blue!20, minimum size=0.9cm, font=\small},
  obs/.style={circle, draw=red, fill=red!20, minimum size=0.9cm, font=\small,
              double, double distance=1pt},
  mean/.style={rectangle, draw=green, fill=green!20,
               minimum width=1.2cm, minimum height=0.7cm, font=\small}
]
\node[obs]   (y)  {$\bm{y}$};
\node[latent,above=of y]  (mu) {$\bm{\mu}$};
\node[latent,left=of mu]  (z)  {$\bm{z}$};
\node[latent,right=of mu] (w)  {$\bm{w}$};
\node[mean,above=of mu]   (theta) {$\bm{\theta}$};

\draw[->, thick] (z) -- (mu);
\draw[->, thick] (w) -- (mu);
\draw[->, thick] (mu) -- (y);
\draw[->, thick, dashed] (theta) -- (mu);
\draw[->, thick, dashed] (theta) -- (z);
\draw[->, thick, dashed] (theta) -- (w);
\end{tikzpicture}
```

### Commutative Diagram (tikz-cd)

```latex
\usetikzlibrary{cd}
\[
\begin{tikzcd}[column sep=large, row sep=large]
\mathcal{F} \arrow[r, "T", "\simeq"'] \arrow[d, "\pi"'] &
\hat{\mathcal{F}} \arrow[d, "\hat{\pi}"] \\
\mathcal{B} \arrow[r, "f"'] \arrow[ur, dashed, "g"'] &
\mathcal{C}
\end{tikzcd}
\]
```

## Integration with PGFplots

PGFplots handles 2D/3D function plots, parametric curves, and heatmaps. Pair with TikZ for mixed diagram+plot figures (e.g., a model architecture with a loss-curve inset).

```latex
\begin{tikzpicture}
\begin{axis}[
  xlabel={Epoch}, ylabel={Loss},
  legend pos=north east, grid=major,
  width=8cm, height=6cm
]
  \addplot[blue, thick] coordinates {(1,0.95) (10,0.45) (50,0.08)};
  \addlegendentry{Training}
  \addplot[red, thick, dashed] coordinates {(1,0.98) (10,0.52) (50,0.28)};
  \addlegendentry{Validation}
\end{axis}
\end{tikzpicture}
```

## Tips for Publication-Quality Figures

### Style Guidelines
1. **Font consistency**: same family as the document body; minimum 8pt for axis labels
2. **Color**: use colorblind-friendly palettes (Okabe–Ito: see `figura` skill); avoid red-green only
3. **Size**: vector output is infinitely scalable; design at print size to judge legibility
4. **Labeling**: label all axes with units; (a), (b), (c) for sub-figures

### Exporting Standalone TikZ Figures
```latex
\documentclass[tikz, border=2mm]{standalone}
\usetikzlibrary{arrows.meta, positioning}
\begin{document}
\begin{tikzpicture}
  % ... your diagram ...
\end{tikzpicture}
\end{document}
% In your main document:
% \includegraphics{standalone.pdf}
```

## Useful TikZ Libraries

| Library | Purpose |
|---------|---------|
| `positioning` | Relative node placement (right=of, below=of) |
| `arrows.meta` | Modern arrow tip styles |
| `shapes.geometric` | Diamond, trapezium, ellipse nodes |
| `calc` | Coordinate calculations |
| `fit` | Fit a node around a set of other nodes |
| `decorations.pathreplacing` | Braces, snakes, zigzag lines |
| `backgrounds` | Draw behind other elements |
| `matrix` | Grid-based node layouts |
| `bayesnet` | Latent / observed / parameter nodes + plate notation |
| `cd` | Commutative diagrams |
| `shadows.blur` | Drop shadows for depth |
| `trees` | Tree structures |
| `chains` | Linked node chains |

## When to Use Each Companion Skill

- **figura** (this `skills/figura/` folder): for the **render→view→fix loop**, visual defect catalog, Okabe–Ito palette templates, `standalone` document class policy
- **academic-research-assistant / visualization_agent** (in `academic-research-skills/`): for **data-driven matplotlib/seaborn/ggplot2** visualizations (bar, violin, heatmap, forest plot, etc.)
- **mcp_drawio-official_*** : for **mermaid/CSV** → diagram rendering, including flowcharts and system architecture
