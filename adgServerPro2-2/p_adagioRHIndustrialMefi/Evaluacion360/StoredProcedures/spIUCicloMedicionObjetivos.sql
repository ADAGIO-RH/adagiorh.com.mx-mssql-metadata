USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Evaluacion360].[spIUCicloMedicionObjetivos](
	@IDCicloMedicionObjetivo int = 0
	,@Nombre varchar(255)
	,@FechaInicio date 
	,@FechaFin date
	,@IDEstatusCicloMedicion int
    ,@FechaParaActualizacionEstatusObjetivos datetime
    ,@PermitirIngresoObjetivosEmpleados bit    
    ,@EmpleadoApruebaObjetivos bit
	,@IDUsuario int
) as
begin
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@IDIdioma varchar(20)
	;

	set @Nombre = UPPER(@Nombre)

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	if (isnull(@IDCicloMedicionObjetivo, 0) = 0)
	begin
		if exists(
			select top 1 1 
			from Evaluacion360.tblCatCiclosMedicionObjetivos
			where Nombre = @Nombre
		)
		begin
			THROW 50000, 'Ya exise un Ciclo con el nombre ', 1;
		end;

		insert Evaluacion360.tblCatCiclosMedicionObjetivos(
			Nombre
			,FechaInicio
			,FechaFin
			,IDEstatusCicloMedicion
            ,FechaParaActualizacionEstatusObjetivos
            ,PermitirIngresoObjetivosEmpleados
            ,EmpleadoApruebaObjetivos
			,IDUsuario
		)
		values (
			 @Nombre
			,@FechaInicio
			,@FechaFin
			,@IDEstatusCicloMedicion
            ,@FechaParaActualizacionEstatusObjetivos
            ,@PermitirIngresoObjetivosEmpleados
            ,@EmpleadoApruebaObjetivos
			,@IDUsuario
		)

		Set @IDCicloMedicionObjetivo = @@IDENTITY

		select @NewJSON = a.JSON 
		from (
			select 
				ccmo.IDCicloMedicionObjetivo
		        ,UPPER(ccmo.Nombre) as Nombre
		        ,ccmo.FechaInicio
		        ,ccmo.FechaFin
		        ,ccmo.IDEstatusCicloMedicion
		        ,JSON_VALUE(ecm.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as EstatusCicloMedicion
		        ,ccmo.FechaParaActualizacionEstatusObjetivos
                ,ccmo.PermitirIngresoObjetivosEmpleados
                ,ccmo.EmpleadoApruebaObjetivos
                ,ccmo.IDUsuario
		        ,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario  
			from Evaluacion360.tblCatCiclosMedicionObjetivos ccmo
				join Evaluacion360.tblCatEstatusCiclosMedicion ecm on ecm.IDEstatusCicloMedicion = ccmo.IDEstatusCicloMedicion
				join Seguridad.tblUsuarios u on u.IDUsuario = ccmo.IDUsuario
			WHERE ccmo.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'Evaluacion360.tblCatCiclosMedicionObjetivos',' Evaluacion360.spIUCicloMedicionObjetivos','INSERT',@NewJSON,''
	end else
	begin
		select @OldJSON = a.JSON 
		from (
			select 
				ccmo.IDCicloMedicionObjetivo
		        ,UPPER(ccmo.Nombre) as Nombre
		        ,ccmo.FechaInicio
		        ,ccmo.FechaFin
		        ,ccmo.IDEstatusCicloMedicion
		        ,JSON_VALUE(ecm.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as EstatusCicloMedicion
		        ,ccmo.FechaParaActualizacionEstatusObjetivos
                ,ccmo.PermitirIngresoObjetivosEmpleados
                ,ccmo.EmpleadoApruebaObjetivos
                ,ccmo.IDUsuario
		        ,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario  
			from Evaluacion360.tblCatCiclosMedicionObjetivos ccmo
				join Evaluacion360.tblCatEstatusCiclosMedicion ecm on ecm.IDEstatusCicloMedicion = ccmo.IDEstatusCicloMedicion
				join Seguridad.tblUsuarios u on u.IDUsuario = ccmo.IDUsuario
			WHERE ccmo.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

	
		update Evaluacion360.tblCatCiclosMedicionObjetivos
			set  
				 Nombre					                = @Nombre
				,FechaInicio			                = @FechaInicio
				,FechaFin				                = @FechaFin
				,IDEstatusCicloMedicion	                = @IDEstatusCicloMedicion
                ,FechaParaActualizacionEstatusObjetivos = @FechaParaActualizacionEstatusObjetivos
                ,PermitirIngresoObjetivosEmpleados      = @PermitirIngresoObjetivosEmpleados
                ,EmpleadoApruebaObjetivos               = @EmpleadoApruebaObjetivos
		where IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo
				
		select @NewJSON = a.JSON 
		from (
			select 
				ccmo.IDCicloMedicionObjetivo
		        ,UPPER(ccmo.Nombre) as Nombre
		        ,ccmo.FechaInicio
		        ,ccmo.FechaFin
		        ,ccmo.IDEstatusCicloMedicion
		        ,JSON_VALUE(ecm.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as EstatusCicloMedicion
		        ,ccmo.FechaParaActualizacionEstatusObjetivos
                ,ccmo.PermitirIngresoObjetivosEmpleados
                ,ccmo.EmpleadoApruebaObjetivos
                ,ccmo.IDUsuario
		        ,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario  
			from Evaluacion360.tblCatCiclosMedicionObjetivos ccmo
				join Evaluacion360.tblCatEstatusCiclosMedicion ecm on ecm.IDEstatusCicloMedicion = ccmo.IDEstatusCicloMedicion
				join Seguridad.tblUsuarios u on u.IDUsuario = ccmo.IDUsuario
			WHERE ccmo.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'Evaluacion360.tblCatCiclosMedicionObjetivos',' Evaluacion360.spIUCicloMedicionObjetivos','UPDATE',@NewJSON,@OldJSON
	end
end
GO
