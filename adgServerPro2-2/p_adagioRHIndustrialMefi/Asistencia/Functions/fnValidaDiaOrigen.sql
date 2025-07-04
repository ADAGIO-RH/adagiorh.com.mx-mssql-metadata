USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- ===============================================================  
-- Author...............: Jose Roman  
-- Create date..........: 31/10/2013  
-- Last Date Modified...: 31/10/2013  
-- Description..........: Valida Dia Origen  
--  
-- Versión..............: 1.0  
-- ===============================================================  
CREATE FUNCTION [Asistencia].[fnValidaDiaOrigen](@IDEmpleado int, @Fecha datetime)         
RETURNS  @rtnTable TABLE   
(  
    -- columns returned by the function  
    FechaOrigen Date,  
    TipoChecada nvarchar(255) NULL  
)  
as  
begin  
   
	DECLARE @HAnterioEsNocturno CHAR(1)   
	DECLARE @HChecadaEsNocturno CHAR(1)  
     
	DECLARE @TieneHorarioHoy CHAR(1)   
	DECLARE @TeniaHorarioAyer CHAR(1)  
     
	DECLARE @HorarioAnterior_Entrada DATETIME  
	DECLARE @HorarioAnterior_Salida  DATETIME  
  
	DECLARE @HorarioActual_Entrada  DATETIME  
	DECLARE @HorarioActual_Salida   DATETIME  
  
	DECLARE @ProximoHorario_Entrada DATETIME  
  
	DECLARE @dF1 DATE  
	DECLARE @dF2 DATE  
  
	DECLARE @Resp VARCHAR(2)  
	DECLARE @Dif  FLOAT   
     
	DECLARE @FOrigen date  
     
	SET @Resp    = '';  
	SET @Dif     = 24;  
	SET @TieneHorarioHoy  = 'N';  
	SET @TeniaHorarioAyer = 'N';  
  
	-- FECHA ORIGEN  
	SET @FOrigen    = convert(date,@Fecha,101);   
	--SET @FOrigen     = @Fecha_Checada;   
     
	-- Horario Actual  
	select @HorarioActual_Entrada=(CONVERT(varchar, he.Fecha,112)+' '+convert(varchar,h.HoraEntrada,108)) ,   
			@HorarioActual_Salida = (convert(varchar, he.Fecha,112 )+' '+convert(varchar,h.HoraSalida,108))   
	from Asistencia.tblHorariosEmpleados he with (nolock)  
		left join Asistencia.tblCatHorarios h with (nolock) on he.IDHorario = h.IDHorario    
	where (he.IDEmpleado = @IDEmpleado) and (he.Fecha = cast( @Fecha  as date))   
     
	set @HorarioActual_Entrada = COALESCE(@HorarioActual_Entrada,NULL)  
	set @HorarioActual_Salida  = COALESCE(@HorarioActual_Salida,NULL)  
     
   --  BUSCAR HORARIO ANTERIOR  
	select @HorarioAnterior_Entrada= (CONVERT(varchar, he.Fecha,112)+' '+convert(varchar,h.HoraEntrada,108)) ,   
			@HorarioAnterior_Salida = (convert(varchar, he.Fecha,112 )+' '+convert(varchar,h.HoraSalida,108))   
	from Asistencia.tblHorariosEmpleados he with (nolock)    
		left join Asistencia.tblCatHorarios h with (nolock) on he.IDHorario = h.IDHorario   
	where (he.IDEmpleado = @IDEmpleado) and (He.Fecha = cast(DATEADD(DAY,-1, @Fecha) as date ))   
     
	set @HorarioAnterior_Entrada = COALESCE(@HorarioAnterior_Entrada,NULL)  
	set @HorarioAnterior_Salida  = COALESCE(@HorarioAnterior_Salida,NULL)  
     
   -- BUSCAR HORARIO PROXIMO DIA  
	select @ProximoHorario_Entrada= (CONVERT(varchar, he.Fecha,112)+' '+convert(varchar,h.HoraEntrada,108))   
	from Asistencia.tblHorariosEmpleados he with (nolock)   
		left join Asistencia.tblCatHorarios h with (nolock) on he.IDHorario = h.IDHorario   
	where (he.IDEmpleado = @IDEmpleado) and (He.Fecha = cast(DATEADD(DAY,1, @Fecha) as date ))   
   
	set @ProximoHorario_Entrada = COALESCE(@ProximoHorario_Entrada,NULL)  
   
	--Verificamos si tiene horarios para el dia de hoy.  
	IF @HorarioActual_Entrada IS NOT NULL  
	BEGIN  
		SET @TieneHorarioHoy = 'S';  
		SET @HorarioActual_Entrada = DATEADD(SECOND,1,@HorarioActual_Entrada);  
		SET @HorarioActual_Salida  = DATEADD(SECOND,1,@HorarioActual_Salida);  
        
		-- Verificamos Si tiene horiario anterior  
		IF @HorarioAnterior_Entrada IS NOT NULL  
		BEGIN  
			SET @TeniaHorarioAyer = 'S'  
			SET @HorarioAnterior_Entrada = DATEADD(SECOND,1,@HorarioAnterior_Entrada);  
			SET @HorarioAnterior_Salida  = DATEADD(SECOND,1,@HorarioAnterior_Salida);  
		END    
   
		-- Verificamos si tiene Horario el Próximo dia  
		IF @ProximoHorario_Entrada IS NOT NULL  
		BEGIN  
			SET @ProximoHorario_Entrada = DATEADD(SECOND,1,@ProximoHorario_Entrada);  
		END  
        
        -- Verificamos si son Nocturnos o no los horarios  
        IF (@HorarioActual_Salida < @HorarioActual_Entrada)   
		   SET @HChecadaEsNocturno = 'S' ELSE  
		   SET @HChecadaEsNocturno = 'N'  
       
        IF (@HorarioAnterior_Salida < @HorarioAnterior_Entrada)   
		   SET @HAnterioEsNocturno = 'S' ELSE  
		   SET @HAnterioEsNocturno = 'N'  
         
        -- Si El horario es nocturo Aumentamos un dia a la salida por que es del dia sigiente!  
		IF @HChecadaEsNocturno = 'S'  
			SET @HorarioActual_Salida = DATEADD(DAY,1,@HorarioActual_Salida);  

		IF @HAnterioEsNocturno = 'S'   
			SET @HorarioAnterior_Salida = DATEADD(DAY,1,@HorarioAnterior_Salida);  
       
		-- Determinar si es Entrada o Salida  
		IF (abs(CONVERT(FLOAT,@HorarioAnterior_Salida) - CONVERT(FLOAT,@Fecha)) <= @Dif)   
		begin  
			SET @Resp		= 'ST';  
			SET @FOrigen	= DATEADD(DAY,-1,@Fecha);  
			SET @Dif		= abs(CONVERT(FLOAT,@HorarioAnterior_Salida) - CONVERT(FLOAT,@Fecha));  
		end;  

		if (Abs(CONVERT(FLOAT,@HorarioAnterior_Entrada) - CONVERT(FLOAT,@Fecha)) <= @Dif)   
		begin  
			SET @Resp      = 'ET';  
			SET @FOrigen   = DATEADD(DAY,-1,@Fecha);  
			SET @Dif       = Abs(CONVERT(FLOAT,@HorarioAnterior_Entrada) - CONVERT(FLOAT,@Fecha));  
		end;  

		if (Abs(CONVERT(FLOAT,@HorarioActual_Entrada) - CONVERT(FLOAT,@Fecha)) <= @Dif)   
		begin  
			SET @Resp      = 'ET';  
			SET @FOrigen   = @HorarioActual_Entrada;  
			SET @Dif       = Abs(CONVERT(FLOAT,@HorarioActual_Entrada) - CONVERT(FLOAT,@Fecha));  
		end;  

		if (Abs(CONVERT(FLOAT,@HorarioActual_Salida) - CONVERT(FLOAT,@Fecha)) <= @Dif)   
		begin  
			SET @Resp      = 'ST';  
			SET @FOrigen   = @Fecha;  
			SET @Dif       = Abs(CONVERT(FLOAT,@HorarioActual_Salida) - CONVERT(FLOAT,@Fecha));  
		end;  

		if (Abs(CONVERT(FLOAT,@ProximoHorario_Entrada) - CONVERT(FLOAT,@Fecha)) <= @Dif)   
		begin  
			SET @Resp       = 'ET';  
			SET @FOrigen    = DATEADD(DAY,1,@Fecha);  
			SET @Dif        = Abs(CONVERT(FLOAT,@ProximoHorario_Entrada) - CONVERT(FLOAT,@Fecha));  
		end;  
   
		-- Buscamos las checadas del dia para verificar si tiene ya una entrada ese dia.  
		-- En caso de ya tener una entrada, automáticamente se le pone salida a todas las  
		-- demás checadas del dia.  
  
		IF exists(select top 1 1 from Asistencia.tblChecadas with(nolock) where (IDEmpleado = @IDEmpleado) and (FechaOrigen = @FOrigen) and (IDTipoChecada = 'ET'))
		BEGIN  
			SET @Resp  = 'ST';  
		END;  
	END  
	ELSE  
	BEGIN  
		SET @Resp = 'SH';  
	END  
   
   
 /* ELSE  
 BEGIN  
    -- Verificamos Si tiene horiario anterior  
  IF @HorarioAnterior_Entrada IS NOT NULL  
  BEGIN  
   SET @TeniaHorarioAyer = 'S'  
   SET @HorarioAnterior_Entrada = DATEADD(SECOND,1,@HorarioAnterior_Entrada);  
            SET @HorarioAnterior_Salida  = DATEADD(SECOND,1,@HorarioAnterior_Salida);  
  END    
   
  -- Verificamos si tiene Horario el Próximo dia  
    
  IF @ProximoHorario_Entrada IS NOT NULL  
  BEGIN  
   SET @ProximoHorario_Entrada = DATEADD(SECOND,1,@ProximoHorario_Entrada);  
  END  
        
        -- Verificamos si son Nocturnos o no los horarios  
        IF (@HorarioActual_Salida < @HorarioActual_Entrada)   
   SET @HChecadaEsNocturno = 'S' ELSE  
   SET @HChecadaEsNocturno = 'N'  
       
        IF (@HorarioAnterior_Salida < @HorarioAnterior_Entrada)   
   SET @HAnterioEsNocturno = 'S' ELSE  
   SET @HAnterioEsNocturno = 'N'  
         
        -- Si El horario es nocturo Aumentamos un dia a la salida por que es del dia sigiente!  
  IF @HChecadaEsNocturno = 'S'  
   SET @HorarioActual_Salida = DATEADD(DAY,1,@HorarioActual_Salida);  
  IF @HAnterioEsNocturno = 'S'   
           SET @HorarioAnterior_Salida = DATEADD(DAY,1,@HorarioAnterior_Salida);  
       
  -- Determinar si es Entrada o Salida  
    IF (abs(CONVERT(FLOAT,@HorarioAnterior_Salida) - CONVERT(FLOAT,@Fecha_Checada)) <= @Dif)   
    begin  
    SET @FOrigen  = DATEADD(DAY,-1,@Fecha_Checada);  
    SET @Dif      = abs(CONVERT(FLOAT,@HorarioAnterior_Salida) - CONVERT(FLOAT,@Fecha_Checada));  
    end;  
  if (Abs(CONVERT(FLOAT,@HorarioAnterior_Entrada) - CONVERT(FLOAT,@Fecha_Checada)) <= @Dif)   
    begin  
    SET @FOrigen   = DATEADD(DAY,-1,@Fecha_Checada);  
    SET @Dif       = Abs(CONVERT(FLOAT,@HorarioAnterior_Entrada) - CONVERT(FLOAT,@Fecha_Checada));  
    end;  
    if (Abs(CONVERT(FLOAT,@HorarioActual_Entrada) - CONVERT(FLOAT,@Fecha_Checada)) <= @Dif)   
    begin   
    SET @FOrigen   = @HorarioActual_Entrada;  
    SET @Dif       = Abs(CONVERT(FLOAT,@HorarioActual_Entrada) - CONVERT(FLOAT,@Fecha_Checada));  
    end;  
    if (Abs(CONVERT(FLOAT,@HorarioActual_Salida) - CONVERT(FLOAT,@Fecha_Checada)) <= @Dif)   
    begin  
    SET @FOrigen   = @Fecha_Checada;  
    SET @Dif       = Abs(CONVERT(FLOAT,@HorarioActual_Salida) - CONVERT(FLOAT,@Fecha_Checada));  
    end;  
  if (Abs(CONVERT(FLOAT,@ProximoHorario_Entrada) - CONVERT(FLOAT,@Fecha_Checada)) <= @Dif)   
    begin  
    SET @FOrigen    = DATEADD(DAY,1,@Fecha_Checada);  
    SET @Dif        = Abs(CONVERT(FLOAT,@ProximoHorario_Entrada) - CONVERT(FLOAT,@Fecha_Checada));  
    end;  
 END;  
 */   
  
	insert into @rtnTable(FechaOrigen,TipoChecada)  
	values (@FOrigen,@Resp)  
   
	RETURN;  
end
GO
