USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Auditoria].[spIAuditoria]
(
	@IDUsuario int,
	@Tabla Varchar(100),
	@Procedimiento Varchar(255),
	@Accion Varchar(255),
	@NewData Varchar(MAX),
	@OldData Varchar(MAX),
	@Mensaje Varchar(MAX) = null,
	@InformacionExtra varchar(max) = null
)
AS
BEGIN
	DECLARE 
		@IDEmpleadoNew varchar(max) = null
		,@IDEmpleadoOld varchar(max)  = null
		,@IDEmpleado int
	;

	select 
		@IDEmpleadoNew = replace(replace(replace(replace(item,'"IDEmpleado":"',''),'"','') ,'{',''),'}','')
	from app.Split(@NewData,',')
	where item like '%"IDEmpleado":"%'

	select 
		@IDEmpleadoOld = replace(replace(replace(replace(item,'"IDEmpleado":"',''),'"','') ,'{',''),'}','')
	from app.Split(@OldData,',')
	where item like '%"IDEmpleado":"%'

	set @IDEmpleado = case when isnull(@IDEmpleadoNew,0) >= isnull(@IDEmpleadoOld,0) then @IDEmpleadoNew else @IDEmpleadoOld end

	insert into [Auditoria].[tblAuditoria](IDUsuario,Fecha,Tabla,Procedimiento,Accion,NewData,OldData, IDEmpleado, Mensaje, InformacionExtra)
	Values (@IDUsuario,GETDATE(),@Tabla,@Procedimiento,@Accion,@NewData,@OldData, @IDEmpleado, @Mensaje,@InformacionExtra)

	if ((@Tabla like '%empleado%') and  isnull(@IDEmpleado,0) > 0)
	begin
		exec RH.spIUUltimaActualizacionEmpleado @IDEmpleado = @IDEmpleado
	end
END
GO
