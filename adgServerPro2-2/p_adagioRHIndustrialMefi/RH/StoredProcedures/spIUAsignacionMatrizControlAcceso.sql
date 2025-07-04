USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Asignacion de controles de acceso a la plaza
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-08-03
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   proc [RH].[spIUAsignacionMatrizControlAcceso](		
	@IDMatrizControlAcceso int,
    @IDEmpleado int ,
	@Value bit ,
	@IDUsuario int
) as 
	DECLARE 
		@OldJSON varchar(Max),
		@NewJSON varchar(Max),
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

    declare @IDAsignacionMatrizControlAcceso int 
    
    select  @IDAsignacionMatrizControlAcceso=IDAsignacionMatrizControlAcceso from 
            RH.tblAsignacionesMatrizControlAcceso where 
            IDEmpleado=@IDEmpleado and IDMatrizControlAcceso=@IDMatrizControlAcceso
    

	if (isnull(@IDAsignacionMatrizControlAcceso, 0) = 0)
	begin
		insert RH.tblAsignacionesMatrizControlAcceso(IDEmpleado,IDMatrizControlAcceso,Value)
		values(@IDEmpleado, @IDMatrizControlAcceso,@Value)

		set @IDAsignacionMatrizControlAcceso = @@IDENTITY

		-- select @NewJSON = a.JSON 
		-- from (
		-- 	select 
		-- 		de.IDDatoExtra
		-- 		,de.IDTipoDatoExtra
		-- 		,de.IDInputType
		-- 		,de.Traduccion
		-- 		,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
		-- 		,de.[Data]
		-- 		,de.IDUsuario
		-- 		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
		-- 		,de.FechaHoraReg
		-- 	from App.tblCatDatosExtras de
		-- 		join Seguridad.tblUsuarios u on u.IDUsuario = de.IDUsuario
		-- 	where IDDatoExtra = @IDDatoExtra
		-- ) b
		-- 	cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		-- EXEC [Auditoria].[spIAuditoria] @IDUsuario,'App.tblCatDatosExtras',' App.spIUCatDatoExtra','INSERT',@NewJSON,''
		
	end else
	begin
		-- select @OldJSON = a.JSON 
		-- from (
		-- 	select 
		-- 		de.IDDatoExtra
		-- 		,de.IDTipoDatoExtra
		-- 		,de.IDInputType
		-- 		,de.Traduccion
		-- 		,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
		-- 		,de.[Data]
		-- 		,de.IDUsuario
		-- 		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
		-- 		,de.FechaHoraReg
		-- 	from App.tblCatDatosExtras de
		-- 		join Seguridad.tblUsuarios u on u.IDUsuario = de.IDUsuario
		-- 	where IDDatoExtra = @IDDatoExtra
		-- ) b
		-- 	cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		update RH.tblAsignacionesMatrizControlAcceso
			set
				Value=@Value
		where IDAsignacionMatrizControlAcceso = @IDAsignacionMatrizControlAcceso

		-- select @NewJSON = a.JSON 
		-- from (
		-- 	select 
		-- 		de.IDDatoExtra
		-- 		,de.IDTipoDatoExtra
		-- 		,de.IDInputType
		-- 		,de.Traduccion
		-- 		,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
		-- 		,de.[Data]
		-- 		,de.IDUsuario
		-- 		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
		-- 		,de.FechaHoraReg
		-- 	from App.tblCatDatosExtras de
		-- 		join Seguridad.tblUsuarios u on u.IDUsuario = de.IDUsuario
		-- 	where IDDatoExtra = @IDDatoExtra
		-- ) b
		-- 	cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		-- EXEC [Auditoria].[spIAuditoria] @IDUsuario,'App.tblCatDatosExtras',' App.spIUCatDatoExtra','UPDATE',@NewJSON,@OldJSON
	end

	-- exec App.spBuscarCatDatosExtras @IDDatoExtra=@IDDatoExtra, @IDUsuario=@IDUsuario

    select @IDAsignacionMatrizControlAcceso as IDAsignacionMatrizControlAcceso
GO
