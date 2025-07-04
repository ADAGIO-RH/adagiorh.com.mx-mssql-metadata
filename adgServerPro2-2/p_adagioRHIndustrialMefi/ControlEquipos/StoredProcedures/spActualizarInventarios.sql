USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [ControlEquipos].[spActualizarInventarios](
	@IDUsuario int
	,@IDArticulo int
)
as
begin
	declare @Cantidad int, @Stock int;

    declare @estatusArticulos as table (
        IDCatEstatusArticulos int ,
        IDDetalleArticulo int 
    );
    
    WITH CTE AS (
            SELECT
                IDCatEstatusArticulo,IDDetalleArticulo,
                ROW_NUMBER() OVER (PARTITION BY IDDetalleArticulo ORDER BY FechaHora desc) AS RowNum
            FROM
                ControlEquipos.tblEstatusArticulos  ea
                
        )
    insert into @estatusArticulos(IDCatEstatusArticulos,IDDetalleArticulo)
    select IDCatEstatusArticulo,CTE.IDDetalleArticulo from CTE
    inner join ControlEquipos.tblDetalleArticulos  da on CTE.IDDetalleArticulo=da.IDDetalleArticulo                
    where RowNum = 1 and IDArticulo=@IDArticulo;
        
--select * from @estatusArticulos
     
    select @Cantidad = count(*) from @estatusArticulos WHERE IDCatEstatusArticulos IN (1,2,3,6,8);

    select @Stock = count(*) from @estatusArticulos WHERE IDCatEstatusArticulos IN (1,6);
    

	UPDATE ControlEquipos.tblArticulos
		SET
			Cantidad = @Cantidad,
			Stock = @Stock
		WHERE IDArticulo = @IDArticulo
end
GO
