USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblRespaldoReportesTRDP](
	[IDRespaldoReportesTRDP] [int] IDENTITY(1,1) NOT NULL,
	[IDReporteBasico] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Notas] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RutaRespaldo] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
 CONSTRAINT [Pk_ApptblRespaldoReportesTRDP_IDRespaldoReportesTRDP] PRIMARY KEY CLUSTERED 
(
	[FechaRegistro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblRespaldoReportesTRDP] ADD  DEFAULT (getdate()) FOR [FechaRegistro]
GO
