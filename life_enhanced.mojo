# Life Game Implementation in Mojo
# Enhanced version with type annotations and documentation

from collections import List


def count_neighbors(grid: List[List[Bool]], x: Int, y: Int) -> Int:
    """计算指定位置周围的活细胞数量
    
    Args:
        grid: 生命游戏网格
        x: 行索引
        y: 列索引
    
    Returns:
        周围活细胞的数量
    """
    count = 0
    rows = len(grid)
    cols = len(grid[0]) if rows > 0 else 0
    
    for i in range(max(0, x - 1), min(rows, x + 2)):
        for j in range(max(0, y - 1), min(cols, y + 2)):
            if i != x or j != y:
                if grid[i][j]:
                    count += 1
    return count


def next_generation(grid: List[List[Bool]]) -> List[List[Bool]]:
    """计算生命游戏的下一代状态
    
    规则:
    1. 活细胞周围有2-3个活邻居则存活
    2. 死细胞周围有3个活邻居则复活
    3. 其他情况死亡
    
    Args:
        grid: 当前网格状态
    
    Returns:
        下一代网格状态
    """
    rows = len(grid)
    cols = len(grid[0]) if rows > 0 else 0
    
    new_grid: List[List[Bool]] = []
    
    for i in range(rows):
        new_row: List[Bool] = []
        for j in range(cols):
            neighbors = count_neighbors(grid, i, j)
            
            if grid[i][j]:
                new_row.append(neighbors == 2 or neighbors == 3)
            else:
                new_row.append(neighbors == 3)
        new_grid.append(new_row)
    
    return new_grid


def print_grid(grid: List[List[Bool]]) -> None:
    """打印网格状态
    
    Args:
        grid: 要打印的网格
    """
    for row in grid:
        line = ""
        for cell in row:
            line += "■ " if cell else "□ "
        print(line)


def main() -> None:
    """主函数：演示生命游戏"""
    print("=== Conway's Game of Life ===")
    print()
    
    grid: List[List[Bool]] = [
        [False, True, False],
        [False, True, False],
        [False, True, False],
    ]
    
    print("初始状态 (闪烁器模式):")
    print_grid(grid)
    
    print("
下一代:")
    grid = next_generation(grid)
    print_grid(grid)
    
    print("
再下一代:")
    grid = next_generation(grid)
    print_grid(grid)
    
    print("
生命游戏演示完成!")


if __name__ == "__main__":
    main()
