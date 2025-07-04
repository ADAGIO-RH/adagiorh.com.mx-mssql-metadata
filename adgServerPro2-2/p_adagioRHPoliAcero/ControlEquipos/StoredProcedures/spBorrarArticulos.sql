USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBorrarArticulos](
	@IDArticulo int,
    @IDUsuario int,
	@ConfirmarEliminar BIT = 0
)
as
begin

	declare @ID_CAT_ESTATUS_ARTICULO_ASIGNADO int = 2, 
            @IDDetallesArticulos int,
            @Mensaje  VARCHAR(MAX) = '',
            @Accion		varchar(20)	= 'DELETE',
		    @CustomMessage varchar(max),
		    @tran int;

    BEGIN TRY
        set @tran = @@TRANCOUNT

        set @IDDetallesArticulos = (select count(IDDetalleArticulo) from ControlEquipos.tblDetalleArticulos where IDArticulo = @IDArticulo)

        IF (@ConfirmarEliminar = 0) 
        BEGIN

             IF EXISTS (select top 1 1 from [ControlEquipos].[tblArticulos] where IDArticulo = @IDArticulo)
            BEGIN
                SET @Mensaje = '<li>Existen ' + cast(@IDDetallesArticulos as varchar(10)) + ' detalle(s) de artículo(s) relacionado(s) a este artículo, por lo tanto no puedes borrar este artículo hasta que borres todos los detalles relacionados a este artículo..</li>'
            END    

            IF  (select  COUNT(DA.IDDetalleArticulo) from ControlEquipos.tblArticulos A
                    left join ControlEquipos.tblDetalleArticulos DA on A.IDArticulo = DA.IDArticulo
                    left JOIN ControlEquipos.tblEstatusArticulos hea on  DA.IDDetalleArticulo = hea.IDDetalleArticulo
                    left join ControlEquipos.tblCatEstatusArticulos cea on cea.IDCatEstatusArticulo = hea.IDCatEstatusArticulo
                    left join Seguridad.tblUsuarios U on U.IDUsuario = hea.IDUsuario
                    Where A.IDArticulo = @IDArticulo) > 0
            BEGIN
                SET @Mensaje = ISNULL(@Mensaje, '') + '<li>El articulo cuenta con un historial.</li>'
            END    

            IF (@Mensaje IS NOT NULL AND @Mensaje <> '')
            BEGIN            
                SET @Mensaje = '<p>Nota: el articulo que intenta eliminar tiene las siguientes condiciones:</p>' + @Mensaje
                SELECT @Mensaje AS Mensaje, 1 AS TipoRespuesta
                RETURN            
            END
            ELSE
            BEGIN
                SET @ConfirmarEliminar = 1
            END
        END

        IF(@ConfirmarEliminar = 1)
		BEGIN 
			BEGIN TRANSACTION TranBorrarArticulo  

				        delete from [ControlEquipos].[tblArticulos] where IDArticulo = @IDArticulo

                SELECT 'Articulo eliminado correctamente.' as Mensaje
                   ,0 as TipoRespuesta
                
				COMMIT TRANSACTION TranBorrarArticulo
		END


    END TRY

    BEGIN CATCH
    	set @tran = @@TRANCOUNT
		IF (@tran > 0) ROLLBACK TRANSACTION TranBorrarArticulo
		
		set @CustomMessage = ERROR_MESSAGE()
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002',@CustomMessage=@CustomMessage
		return 0;
	END CATCH ;

	
end
GO
