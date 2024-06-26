USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPTUEmpleados1ERCALCMAYO](
	[IDPTUEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDPTU] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[SalarioDiario] [decimal](18, 2) NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[Sindical] [bit] NOT NULL,
	[SalarioAcumuladoReal] [decimal](18, 2) NOT NULL,
	[SalarioAcumuladoTopado] [decimal](18, 2) NOT NULL,
	[DiasVigencia] [int] NOT NULL,
	[DiasADescontar] [int] NULL,
	[Incapacidades] [int] NULL,
	[DiasTrabajados] [int] NOT NULL,
	[PTUPorSalario] [decimal](18, 2) NOT NULL,
	[PTUPorDias] [decimal](18, 2) NOT NULL,
	[TotalPTU] [decimal](19, 2) NULL,
	[PromedioSueldo3Meses] [decimal](18, 2) NULL,
	[PromedioPTU3Anios] [decimal](18, 2) NULL,
	[PTURecomendado] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
