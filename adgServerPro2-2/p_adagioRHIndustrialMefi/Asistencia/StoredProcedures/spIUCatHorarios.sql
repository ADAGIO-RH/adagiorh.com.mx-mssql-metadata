USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spIUCatHorarios](
     @IDHorario	int	 
    ,@IDTurno		int	 
    ,@Codigo		varchar(100)
    ,@Descripcion	varchar(255)
    ,@HoraEntrada	time
    ,@HoraSalida	time
    ,@TiempoDescanso time
	,@TiempoTotal time
	,@JornadaLaboral time
    ,@IDUsuario int
) as
begin
   -- declare @JornadaLaboral time
		 --,@TiempoTotal	time;

		 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	select @Codigo = UPPER(@Codigo)
		 ,@Descripcion = UPPER(@Descripcion)

    --set @TiempoTotal = [Utilerias].[fsRedondeaTime](convert(time,convert(datetime, convert(float,convert(datetime,@HoraSalida)) - convert(float,convert(datetime,@HoraEntrada)))))

    --set @JornadaLaboral = [Utilerias].[fsRedondeaTime](convert(time,convert(datetime, convert(float,convert(datetime,@TiempoTotal)) - convert(float,convert(datetime,@TiempoDescanso)))))

    if (@IDHorario <> 0)
    begin
	   if exists(select top 1 1 from [Asistencia].[tblCatHorarios]
			 where ((Codigo = @Codigo) or (Descripcion = @Descripcion)) 
			  and IDHorario <> @IDHorario)
	   BEGIN
		  exec [App].[spObtenerError] @IDUsuario=@IDUsuario
							 ,@CodigoError='0611001'
		  return;
	   end;
	   select @OldJSON = a.JSON from [Asistencia].[tblCatHorarios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHorario = @IDHorario

	   update [Asistencia].[tblCatHorarios]
	   set  IDTurno	    = @IDTurno
		  ,Codigo		    = @Codigo
		  ,Descripcion	    = @Descripcion
		  ,HoraEntrada	    = @HoraEntrada
		  ,HoraSalida	    = @HoraSalida
		  ,TiempoDescanso  = @TiempoDescanso
		  ,JornadaLaboral  = @JornadaLaboral
		  ,TiempoTotal	    = @TiempoTotal
	   where IDHorario = @IDHorario

	      select @NewJSON = a.JSON from [Asistencia].[tblCatHorarios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHorario = @IDHorario
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatHorarios]','[Asistencia].[spIUCatHorarios]','UPDATE',@NewJSON,@OldJSON
		

    end else
    begin
	   if exists(select top 1 1 from [Asistencia].[tblCatHorarios]
			 where (Codigo = @Codigo) or (Descripcion = @Descripcion))
	   BEGIN
		  exec [App].[spObtenerError] @IDUsuario=@IDUsuario
							 ,@CodigoError='0611001'
		  return;
	   end;

	   insert into [Asistencia].[tblCatHorarios](IDTurno,Codigo,Descripcion,HoraEntrada,HoraSalida,TiempoDescanso,JornadaLaboral,TiempoTotal)
	   select @IDTurno,@Codigo,@Descripcion,@HoraEntrada,@HoraSalida,@TiempoDescanso,@JornadaLaboral,@TiempoTotal

	   set @IDHorario=@@Identity
	   
	      select @NewJSON = a.JSON from [Asistencia].[tblCatHorarios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHorario = @IDHorario
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatHorarios]','[Asistencia].[spIUCatHorarios]','INSERT',@NewJSON,''
		

    end;

    exec  [Asistencia].[spBuscarHorario] @IDHorario=@IDHorario, @IDUsuario=@IDUsuario;
end;
GO
