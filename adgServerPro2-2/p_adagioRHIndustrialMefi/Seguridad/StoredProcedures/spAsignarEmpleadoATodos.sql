USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spAsignarEmpleadoATodos]
(
	@IDEmpleado int
	,@Nombre Varchar(max) = ''
	,@SegundoNombre Varchar(max) = ''
	,@Paterno Varchar(max) = ''
	,@Materno Varchar(max) = ''
    ,@IDUsuario int  =0
)
AS
BEGIN

	 DECLARE @NewJSON Varchar(Max);
	
	insert into Seguridad.tblDetalleFiltrosEmpleadosUsuarios(IDUsuario, IDEmpleado, Filtro, ValorFiltro,IDCatFiltroUsuario)    

	select u.IDUsuario,@IDEmpleado ,'Empleados','Empleados | '+UPPER(coalesce(@Nombre,''))+' '+UPPER(coalesce(@SegundoNombre,''))+' '+UPPER(coalesce(@Paterno,''))+' '+UPPER(coalesce(@Materno,'')),0
	from Seguridad.tblUsuarios u with(nolock)
		inner join Seguridad.tblCatPerfiles p with(nolock)
			on u.IDPerfil = p.IDPerfil
		left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios eu with(nolock)
			on eu.IDEmpleado = @IDEmpleado
			and u.IDUsuario = eu.IDUsuario
	where p.Descripcion <> 'EMPLEADOS'
	and eu.IDDetalleFiltrosEmpleadosUsuarios is null

SELECT @NewJSON = (SELECT * FROM Seguridad.tblDetalleFiltrosEmpleadosUsuarios 
                        WHERE IDEmpleado = @IDEmpleado FOR JSON PATH);
    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]','[Seguridad].[spAsignarEmpleadoATodos]','INSERT',@NewJSON,''
END
GO
