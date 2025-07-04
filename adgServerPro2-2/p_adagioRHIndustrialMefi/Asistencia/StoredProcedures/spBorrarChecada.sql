USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBorrarChecada] (  
	@IDChecada		int   
    ,@IDEmpleado    int   
    ,@IDUsuario     int   
)
AS
BEGIN
	declare 
		 @Fechas [App].[dtFechas] 
		,@CALENDARIO0002 bit = 0 --No Modificar calendario de días anteriores(Permite modificar el día actual)'
		,@CALENDARIO0003 bit = 0 --No Modificar calendraio de mañana en adelante')
		,@FechaOrigen date
		,@DIAS_MODIFICAR_CALENDARIO int = 0 -- Cantidad de días previos para modificar Calendario
		,@DIAS_MODIFICAR_CALENDARIO_DIAS int = 0
		,@DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA date
	;

	BEGIN -- Permisos de calendario
		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.tienepermiso = 1 and cpe.Codigo = 'CALENDARIO0002')
		begin
			set @CALENDARIO0002 = 1
		end;

		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.tienepermiso = 1 and cpe.Codigo = 'CALENDARIO0003')
		begin
			set @CALENDARIO0003 = 1
		end;

		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.tienepermiso = 1 and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO')
		begin
			set @DIAS_MODIFICAR_CALENDARIO = 1

			select @DIAS_MODIFICAR_CALENDARIO_DIAS = CAST(isnull(cpe.[Data], 0) as int)
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.tienepermiso = 1 and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO'
		end;
	END

	select @FechaOrigen = FechaOrigen
	from Asistencia.tblChecadas
	where IDChecada = @IDChecada

	if (@DIAS_MODIFICAR_CALENDARIO = 1)
	begin
		set @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA = DATEADD(DAY, @DIAS_MODIFICAR_CALENDARIO_DIAS * -1, GETDATE())

		if (@FechaOrigen < @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA)
		begin
			select 0 as ID
				,FORMATMESSAGE('No tienes permiso para eliminar checadas mayores a %d dias previos.', @DIAS_MODIFICAR_CALENDARIO_DIAS) as Mensaje
				,-1 as TipoRespuesta
			return;
		end
	end

	insert into @Fechas(Fecha)
    SELECT d
    FROM (
		SELECT d = DATEADD(DAY, rn - 1, @FechaOrigen)
		FROM (
			SELECT TOP 
				(DATEDIFF(DAY, @FechaOrigen, @FechaOrigen) +1) 
				rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
			FROM sys.all_objects AS s1
				CROSS JOIN sys.all_objects AS s2
				-- on my system this would support > 5 million days
			ORDER BY s1.[object_id]
		) AS x
	) AS y;

	DELETE from @Fechas
	where (Fecha < case when @CALENDARIO0002 = 1 then cast(GETDATE() as date) else '1900-01-01' end)
		or (Fecha < case when @CALENDARIO0003 = 1 then cast(dateadd(day,1,GETDATE()) as date) else '1900-01-01' end)


 DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from [Asistencia].[tblChecadas] b
			join @Fechas fecha on b.FechaOrigen = fecha.Fecha
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDChecada = @IDChecada

	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblChecadas]','[Asistencia].[spBorrarChecada]','DELETE','',@OldJSON
		
	delete c
	from Asistencia.tblChecadas c
		join @Fechas fecha on c.FechaOrigen = fecha.Fecha
	where c.IDChecada = @IDChecada

	select @IDChecada as ID  
		,'Checada eliminada correctamente.' as Mensaje  
		,0 as TipoRespuesta  

END
GO
