function Rename-DatabricksCluster ([string] $Pattern, [string] $Replacement, [switch] $PassThru) {
    databricks clusters list --format json |
        ConvertFrom-Json |
        Select-Object -ExpandProperty clusters -PipelineVariable oldCluster |
        Where-Object -Match $Pattern |
        Select-Object cluster_id, num_workers, spark_version, node_type_id, @{ Name = 'cluster_name'; Expression = { $_.cluster_name -replace $Pattern, $Replacement } } -PiplineVariable newCluster |
        ConvertTo-Json |
        ForEach-Object {
            databricks clusters edit --json "`"$($_.Replace('"', '\"'))`""
            if ($PassThru) {
                [PSCustomObject] @{
                    PSTypeName = 'DatabricksClusterRename'
                    Id = $oldCluster.cluster_id
                    Name = $oldCluster.cluster_name
                    NewName = $newCluster.cluster_name
                }
            }
        }
}
