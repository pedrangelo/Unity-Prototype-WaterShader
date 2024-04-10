using UnityEngine;

public class WaterTiler : MonoBehaviour
{
    public GameObject waterTilePrefab; // Assign your water tile prefab in the inspector
    public int tilesX = 5; // Number of tiles in the X direction
    public int tilesZ = 5; // Number of tiles in the Z direction
    public float tileSize = 10f; // Size of your tile, adjust according to your prefab

    void Start()
    {
        GenerateTiles();
    }

    void GenerateTiles()
    {
        for (int x = 0; x < tilesX; x++)
        {
            for (int z = 0; z < tilesZ; z++)
            {
                // Calculate the position for the new tile
                Vector3 tilePosition = new Vector3(x * tileSize, 0, z * tileSize);
                // Adjust by half the grid size to center the grid at the origin
                tilePosition -= new Vector3((tilesX * tileSize) / 2, 0, (tilesZ * tileSize) / 2);
                // Create a new tile at the calculated position
                Instantiate(waterTilePrefab, tilePosition, Quaternion.identity, transform);
            }
        }
    }
}
